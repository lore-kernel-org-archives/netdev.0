From: Kim Phillips <kim.phillips@freescale.com>
Subject: IPsec performance bug
Date: Wed, 19 Oct 2011 21:22:29 -0500
Message-ID: <20111019212229.72078d51.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe005.messaging.microsoft.com ([65.55.88.15]:1520 "EHLO
	TX2EHSOBE010.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755501Ab1JTCY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 22:24:59 -0400
Received: from mail50-tx2 (localhost.localdomain [127.0.0.1])	by
 mail50-tx2-R.bigfish.com (Postfix) with ESMTP id 56BC0D801D1	for
 <netdev@vger.kernel.org>; Thu, 20 Oct 2011 02:24:58 +0000 (UTC)
Received: from TX2EHSMHS012.bigfish.com (unknown [10.9.14.244])	by
 mail50-tx2.bigfish.com (Postfix) with ESMTP id 9074FA3836A	for
 <netdev@vger.kernel.org>; Thu, 20 Oct 2011 02:23:20 +0000 (UTC)
Received: from x9 (x9.am.freescale.net [10.82.120.9])	by
 az33smr02.freescale.net (8.13.1/8.13.0) with SMTP id p9K2NJDw015056	for
 <netdev@vger.kernel.org>; Wed, 19 Oct 2011 21:23:19 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm trying to debug an IPSec forwarding performance slowdown on a
p2020 dual-core powerpc linux box using s/w crypto (no crypto h/w
offload enabled) between vanilla kernel versions 2.6.35 and 3.0.
Using a h/w packet generator set to 64-byte packets, I get the
following results:

v2.6.35: 48.5kpps
v3.0.0:   0.2kpps
v3.0.7:   0.2kpps
v3.1.0-rc9-01707-gf7ba35d (a recent net-next): 13.6kpps

I was able to bisect the problem down to the following commit:

7e1dc7b6f709dfc1a9ab4b320dbe723f45992693 is the first bad commit
commit 7e1dc7b6f709dfc1a9ab4b320dbe723f45992693
Author: David S. Miller <davem@davemloft.net>
Date:   Sat Mar 12 02:42:11 2011 -0500

    net: Use flowi4 and flowi6 in xfrm layer.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

And, indeed, going back one commit (i.e., v2.6.38-rc8-1468-g2032656
and manually applying commit 7313714:  "xfrm: fix
__xfrm_route_forward ()"), brings performance back to ~50kpps from
0.2kpps.

Tracing shows that the commit breaks the route cache [1], and I
understand there is major surgery going on in the area [2], so I
suppose my question is twofold:

(a) was such a large performance drop to be expected for v3.0?

(b) any ideas how to fix?  I don't know much about routing
internals, but in ip_route_input_common(), if I remove the input
interface comparison (rth->rt_route_iif ^ iif), I get some
performance back, but the system becomes unstable (it's booted over
nfs).

Thanks,

Kim

[1]

(a) ip_rcv() to xfrm4_output() WITHOUT "net: Use flowi4 and flowi6
in xfrm layer.":

 0)               |                      ip_rcv() {
 0)               |                        ip_route_input_common() {
 0)   0.832 us    |                          skb_dst_set_noref();
 0)   2.672 us    |                        }
 0)               |                        ip_forward() {
 0)               |                          __xfrm_policy_check() {
 0)               |                            __xfrm_decode_session() {
 0)               |                              xfrm_policy_get_afinfo() {
 0)   0.864 us    |                                _raw_read_lock();
 0)   2.496 us    |                              }
 0)   1.008 us    |                              _decode_session4();
 0)   0.848 us    |                              xfrm_policy_put_afinfo.clone.26();
 0)   7.696 us    |                            }
 0)               |                            flow_cache_lookup() {
 0)   0.864 us    |                              local_bh_disable();
 0)   0.848 us    |                              local_bh_enable();
 0)   4.560 us    |                            }
 0) + 14.864 us   |                          }
 0)               |                          __xfrm_route_forward() {
 0)               |                            __xfrm_decode_session() {
 0)               |                              xfrm_policy_get_afinfo() {
 0)   0.816 us    |                                _raw_read_lock();
 0)   2.496 us    |                              }
 0)   0.912 us    |                              _decode_session4();
 0)   0.848 us    |                              xfrm_policy_put_afinfo.clone.26();
 0)   7.488 us    |                            }
 0)               |                            xfrm_lookup() {
 0)               |                              flow_cache_lookup() {
 0)   0.800 us    |                                local_bh_disable();
 0)               |                                xfrm_bundle_flo_get() {
 0)               |                                  xfrm_bundle_ok.clone.34() {
 0)   0.944 us    |                                    ipv4_dst_check();
 0)   0.800 us    |                                    ipv4_default_mtu();
 0)   0.832 us    |                                    ipv4_dst_check();
 0)   0.816 us    |                                    ipv4_default_mtu();
 0)   7.664 us    |                                  }
 0)   9.344 us    |                                }
 0)   0.832 us    |                                local_bh_enable();
 0) + 14.416 us   |                              }
 0)   0.832 us    |                              get_seconds();
 0)   0.864 us    |                              dst_release();
 0) + 19.552 us   |                            }
 0) + 29.664 us   |                          }
 0)               |                          xfrm4_output() {


(b) ip_rcv() to xfrm4_output() WITH "net: Use flowi4 and flowi6 in
xfrm layer.":

 0)               |                    ip_rcv() {
 0)               |                      ip_route_input_common() {
 0)               |                        fib_lookup() {
 0)               |                          fib_rules_lookup() {
 0)   0.912 us    |                            fib4_rule_match();
 0)               |                            fib4_rule_action() {
 0)   0.992 us    |                              fib_get_table();
 0)               |                              fib_table_lookup() {
 0)   0.976 us    |                                check_leaf.clone.10();
 0)   0.928 us    |                                check_leaf.clone.10();
 0)   5.872 us    |                              }
 0)   9.536 us    |                            }
 0)   0.832 us    |                            fib4_rule_match();
 0)               |                            fib4_rule_action() {
 0)   0.816 us    |                              fib_get_table();
 0)               |                              fib_table_lookup() {
 0)   1.280 us    |                                check_leaf.clone.10();
 0)   3.440 us    |                              }
 0)   6.720 us    |                            }
 0) + 22.944 us   |                          }
 0) + 25.344 us   |                        }
 0)               |                        fib_validate_source() {
 0)               |                          fib_lookup() {
 0)               |                            fib_rules_lookup() {
 0)   0.800 us    |                              fib4_rule_match();
 0)               |                              fib4_rule_action() {
 0)   0.880 us    |                                fib_get_table();
 0)               |                                fib_table_lookup() {
 0)   0.832 us    |                                  check_leaf.clone.10();
 0)   2.688 us    |                                }
 0)   5.952 us    |                              }
 0)   0.816 us    |                              fib4_rule_match();
 0)               |                              fib4_rule_action() {
 0)   0.800 us    |                                fib_get_table();
 0)               |                                fib_table_lookup() {
 0)   1.168 us    |                                  check_leaf.clone.10();
 0)   2.960 us    |                                }
 0)   6.160 us    |                              }
 0) + 17.808 us   |                            }
 0) + 19.392 us   |                          }
 0) + 21.424 us   |                        }
 0)               |                        rt_dst_alloc() {
 0)               |                          dst_alloc() {
 0)   1.200 us    |                            kmem_cache_alloc();
 0)   0.816 us    |                            local_bh_disable();
 0)   0.912 us    |                            local_bh_enable();
 0)   6.816 us    |                          }
 0)   8.496 us    |                        }
 0)               |                        rt_set_nexthop.clone.37() {
 0)   1.392 us    |                          inet_getpeer();
 0)   0.928 us    |                          ipv4_default_mtu();
 0)   5.424 us    |                        }
 0)               |                        rt_intern_hash() {
 0)               |                          _raw_spin_lock_bh() {
 0)   0.880 us    |                            local_bh_disable();
 0)   2.528 us    |                          }
 0)               |                          call_rcu_bh() {
 0)               |                            __call_rcu() {
 0)               |                              force_quiescent_state() {
 0)   0.816 us    |                                _raw_spin_trylock();
 0)   0.928 us    |                                _raw_spin_lock();
 0)               |                                force_qs_rnp() {
 0)   0.848 us    |                                  _raw_spin_lock_irqsave();
 0)   0.960 us    |                                  dyntick_save_progress_counter();
 0)   0.896 us    |                                  dyntick_save_progress_counter();
 0)               |                                  rcu_report_qs_rnp() {
 0)   0.816 us    |                                    _raw_spin_unlock_irqrestore();
 0)   2.576 us    |                                  }
 0) + 10.016 us   |                                }
 0)   0.816 us    |                                _raw_spin_lock();
 0)   0.832 us    |                                _raw_spin_unlock_irqrestore();
 0) + 19.088 us   |                              }
 0) + 21.216 us   |                            }
 0) + 23.824 us   |                          }
 0)               |                          arp_bind_neighbour() {
 0)               |                            neigh_lookup() {
 0)   0.784 us    |                              local_bh_disable();
 0)   0.992 us    |                              arp_hash();
 0)   0.928 us    |                              local_bh_enable();
 0)   7.568 us    |                            }
 0)   9.552 us    |                          }
 0)               |                          _raw_spin_unlock_bh() {
 0)   0.848 us    |                            local_bh_enable_ip();
 0)   2.496 us    |                          }
 0) ! 521.056 us  |                        }
 0) ! 971.952 us  |                      }
 0)               |                      ip_forward() {
 0)               |                        __xfrm_policy_check() {
 0)               |                          __xfrm_decode_session() {
 0)               |                            xfrm_policy_get_afinfo() {
 0)   0.864 us    |                              _raw_read_lock();
 0)   2.576 us    |                            }
 0)   1.248 us    |                            _decode_session4();
 0)   0.896 us    |                            xfrm_policy_put_afinfo.clone.26();
 0)   8.384 us    |                          }
 0)               |                          flow_cache_lookup() {
 0)   0.800 us    |                            local_bh_disable();
 0)   0.816 us    |                            local_bh_enable();
 0)   4.976 us    |                          }
 0) + 16.240 us   |                        }
 0)               |                        __xfrm_route_forward() {
 0)               |                          __xfrm_decode_session() {
 0)               |                            xfrm_policy_get_afinfo() {
 0)   0.912 us    |                              _raw_read_lock();
 0)   2.496 us    |                            }
 0)   0.928 us    |                            _decode_session4();
 0)   0.848 us    |                            xfrm_policy_put_afinfo.clone.26();
 0)   7.408 us    |                          }
 0)               |                          xfrm_lookup() {
 0)               |                            flow_cache_lookup() {
 0)   0.784 us    |                              local_bh_disable();
 0)   1.104 us    |                              kmem_cache_alloc();
 0)               |                              xfrm_bundle_lookup() {
 0)               |                                xfrm_policy_lookup_bytype.clone.37() {
 0)               |                                  _raw_read_lock_bh() {
 0)   0.784 us    |                                    local_bh_disable();
 0)   2.464 us    |                                  }
 0)   1.312 us    |                                  xfrm_selector_match();
 0)               |                                  _raw_read_unlock_bh() {
 0)   0.880 us    |                                    local_bh_enable_ip();
 0)   2.576 us    |                                  }
 0) + 10.800 us   |                                }
 0)               |                                xfrm_resolve_and_create_bundle() {
 0)               |                                  xfrm_state_find() {
 0)               |                                    _raw_spin_lock_bh() {
 0)   0.832 us    |                                      local_bh_disable();
 0)   2.544 us    |                                    }
 0)               |                                    xfrm_state_look_at.clone.18() {
 0)   1.136 us    |                                      xfrm_selector_match();
 0)   2.912 us    |                                    }
 0)               |                                    _raw_spin_unlock_bh() {
 0)   0.800 us    |                                      local_bh_enable_ip();
 0)   2.416 us    |                                    }
 0) + 12.336 us   |                                  }
 0)               |                                  xfrm_policy_get_afinfo() {
 0)   0.816 us    |                                    _raw_read_lock();
 0)   2.528 us    |                                  }
 0)   0.816 us    |                                  xfrm4_get_tos();
 0)   0.832 us    |                                  xfrm_policy_put_afinfo.clone.26();
 0)               |                                  xfrm_policy_get_afinfo() {
 0)   0.832 us    |                                    _raw_read_lock();
 0)   2.496 us    |                                  }
 0)               |                                  dst_alloc() {
 0)   1.200 us    |                                    kmem_cache_alloc();
 0)   0.800 us    |                                    local_bh_disable();
 0)   0.816 us    |                                    local_bh_enable();
 0)   6.400 us    |                                  }
 0)   0.816 us    |                                  xfrm_policy_put_afinfo.clone.26();
 0)               |                                  dst_cow_metrics_generic() {
 0)   1.056 us    |                                    kmem_cache_alloc_trace();
 0)   3.168 us    |                                  }
 0)               |                                  xfrm_policy_get_afinfo() {
 0)   0.816 us    |                                    _raw_read_lock();
 0)   2.416 us    |                                  }
 0)               |                                  xfrm4_dst_lookup() {
 0)               |                                    __ip_route_output_key() {
 0)   0.800 us    |                                      local_bh_disable();
 0)   0.896 us    |                                      local_bh_enable();
 0)   5.616 us    |                                    }
 0)   7.264 us    |                                  }
 0)   0.832 us    |                                  xfrm_policy_put_afinfo.clone.26();
 0)               |                                  xfrm_policy_get_afinfo() {
 0)   0.816 us    |                                    _raw_read_lock();
 0)   2.496 us    |                                  }
 0)   0.800 us    |                                  xfrm4_init_path();
 0)   0.832 us    |                                  xfrm_policy_put_afinfo.clone.26();
 0)   0.832 us    |                                  ipv4_default_mtu();
 0)               |                                  xfrm_state_mtu() {
 0)               |                                    _raw_spin_lock_bh() {
 0)   0.800 us    |                                      local_bh_disable();
 0)   2.448 us    |                                    }
 0)   1.056 us    |                                    esp4_get_mtu();
 0)               |                                    _raw_spin_unlock_bh() {
 0)   0.832 us    |                                      local_bh_enable_ip();
 0)   2.416 us    |                                    }
 0)   9.312 us    |                                  }
 0)   0.816 us    |                                  ipv4_default_mtu();
 0)               |                                  xfrm_policy_get_afinfo() {
 0)   0.816 us    |                                    _raw_read_lock();
 0)   2.496 us    |                                  }
 0)   1.088 us    |                                  xfrm4_fill_dst();
 0)   0.832 us    |                                  xfrm_policy_put_afinfo.clone.26();
 0) + 79.488 us   |                                }
 0) + 93.104 us   |                              }
 0)   0.816 us    |                              local_bh_enable();
 0) ! 101.120 us  |                            }
 0)   0.816 us    |                            get_seconds();
 0)   0.976 us    |                            dst_release();
 0) ! 106.640 us  |                          }
 0) ! 116.656 us  |                        }
 0)               |                        xfrm4_output() {

[2] http://vger.kernel.org/netconf2011_slides/davem_netconf2011.pdf

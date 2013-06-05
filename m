From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: Performance regression from routing cache removal?
Date: Wed, 5 Jun 2013 12:57:24 -0500
Message-ID: <20130605175724.GA2576@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog115.obsmtp.com ([74.125.149.238]:47335 "EHLO
	na3sys009aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757121Ab3FER5f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 13:57:35 -0400
Received: by mail-ob0-f172.google.com with SMTP id wo10so3130260obc.17
        for <netdev@vger.kernel.org>; Wed, 05 Jun 2013 10:57:34 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've got a performance regression that I've been trying to track down
for the last couple of days.  The last known good kernel was 3.4 and
now I'm testing 3.10 so there has been a lot of changes in between.
The workload I'm testing has a single machine receiving UDP multicast
packets across approximately 350 multicast groups.  We've got one
socket per multicast address receiving the data.  The traffic is small
packets and tends to be very bursty.  With the 3.10 kernel I'm seeing
occasional spikes in one-way latency that are in the 100-500
millisecond range, and regularly in the 10 millisecond range.  I've
started a git bisect which has narrowed me down to:

bad f5b0a8743601a4477419171f5046bd07d1c080a0
good fa0afcd10951afad2022dda09777d2bf70cdab3d

The remaining commits are all part of the routing cache removal so
I've stopped my bisection for now.  I can bisect further if anyone
thinks it will be valuable.

Profiling the machine under 3.10-rc3 shows the following new hot spot
on the kernel side:

45.84%  [kernel.kallsyms]
        |
        |--8.55%-- ip_check_mc_rcu
        |          |
        |          |--99.41%-- ip_route_input_noref
        |          |          ip_rcv_finish
        |          |          ip_rcv
        |          |          __netif_receive_skb_core
        |          |          __netif_receive_skb
        |          |          netif_receive_skb
        |          |          napi_gro_frags
        |          |          mlx4_en_process_rx_cq
        |          |          mlx4_en_poll_rx_cq
        |          |          net_rx_action
        |          |          __do_softirq

Digging through the git history the ip_check_mc_rcu appears to be the
result of the routing cache removal.  I've also used trace-cmd to
capture some function graphs and compared between 3.4 and 3.10.  The
ip_check_mc_rcu() is one obvious slowdown and it also appears that
ipv4_pktinfo_prepare() may have slowed down between 3.4 and 3.10 as
well though I have not yet looked to see what has changed there.  Here
is an example of ip_rcv_finish() traced with 3.10 keeping in mind that
the trace does add overhead:

7474.898949: funcgraph_entry              |  ip_rcv_finish() {
7474.898950: funcgraph_entry              |    ip_route_input_noref() {
7474.898951: funcgraph_entry   6.693 us   |      ip_check_mc_rcu();
7474.898958: funcgraph_entry   0.080 us   |      fib_validate_source();
7474.898958: funcgraph_entry              |      rt_dst_alloc() {
7474.898958: funcgraph_entry              |        dst_alloc() {
7474.898958: funcgraph_entry   0.046 us   |          kmem_cache_alloc();
7474.898959: funcgraph_entry   0.029 us   |          local_bh_disable();
7474.898959: funcgraph_entry   0.030 us   |          local_bh_enable();
7474.898959: funcgraph_exit:   1.134 us   |        }
7474.898960: funcgraph_exit:   1.415 us   |      }
7474.898960: funcgraph_exit:   9.269 us   |    }
7474.898960: funcgraph_entry              |    ip_local_deliver() {
7474.898960: funcgraph_entry              |      ip_local_deliver_finish() {
7474.898960: funcgraph_entry   0.054 us   |        raw_local_deliver();
7474.898960: funcgraph_entry              |        udp_rcv() {
7474.898961: funcgraph_entry              |          __udp4_lib_rcv() {
7474.898961: funcgraph_entry              |            __pskb_pull_tail() {
7474.898961: funcgraph_entry   0.129 us   |              skb_copy_bits();
7474.898961: funcgraph_exit:   0.377 us   |            }
7474.898961: funcgraph_entry              |            __udp4_lib_mcast_deliver() {
7474.898962: funcgraph_entry   0.156 us   |              _raw_spin_lock();
7474.898962: funcgraph_entry   0.268 us   |              ip_mc_sf_allow();
7474.898963: funcgraph_entry              |              flush_stack() {
7474.898963: funcgraph_entry              |                udp_queue_rcv_skb() {
7474.898963: funcgraph_entry              |                  ipv4_pktinfo_prepare() {
7474.898963: funcgraph_entry              |                    fib_compute_spec_dst() {
7474.898963: funcgraph_entry              |                      fib_table_lookup() {
7474.898964: funcgraph_entry   0.059 us   |                        check_leaf();
7474.898964: funcgraph_entry   0.030 us   |                        check_leaf();
7474.898964: funcgraph_exit:   0.784 us   |                      }
7474.898964: funcgraph_entry              |                      fib_table_lookup() {
7474.898965: funcgraph_entry   0.181 us   |                        check_leaf();
7474.898965: funcgraph_exit:   0.511 us   |                      }
7474.898965: funcgraph_exit:   1.814 us   |                    }
7474.898965: funcgraph_entry              |                    dst_release() {
7474.898965: funcgraph_entry              |                      dst_destroy() {
7474.898966: funcgraph_entry   0.026 us   |                        local_bh_disable();
7474.898966: funcgraph_entry   0.029 us   |                        local_bh_enable();
7474.898966: funcgraph_entry   0.029 us   |                        ipv4_dst_destroy();
7474.898966: funcgraph_entry   0.065 us   |                        kmem_cache_free();
7474.898967: funcgraph_exit:   1.029 us   |                      }
7474.898967: funcgraph_exit:   1.299 us   |                    }
7474.898967: funcgraph_exit:   3.647 us   |                  }
7474.898967: funcgraph_entry   0.028 us   |                  _raw_spin_lock();
7474.898967: funcgraph_entry              |                  __udp_queue_rcv_skb() {
7474.898967: funcgraph_entry              |                    sock_queue_rcv_skb() {
7474.898967: funcgraph_entry   0.035 us   |                      sk_filter();
7474.898968: funcgraph_entry   0.030 us   |                      _raw_spin_lock_irqsave();
7474.898968: funcgraph_entry   0.032 us   |                      _raw_spin_unlock_irqrestore();
7474.898968: funcgraph_entry              |                      sock_def_readable() {
7474.898968: funcgraph_entry              |                        __wake_up_sync_key() {
7474.898968: funcgraph_entry   0.030 us   |                          _raw_spin_lock_irqsave();
7474.898969: funcgraph_entry              |                          __wake_up_common() {
7474.898969: funcgraph_entry              |                            ep_poll_callback() {
7474.898969: funcgraph_entry   0.129 us   |                              _raw_spin_lock_irqsave();
7474.898970: funcgraph_entry              |                              __wake_up_locked() {
7474.898970: funcgraph_entry              |                                __wake_up_common() {
7474.898970: funcgraph_entry              |                                  default_wake_function() {
7474.898970: funcgraph_entry              |                                    try_to_wake_up() {
7474.898970: funcgraph_entry   0.095 us   |                                      _raw_spin_lock_irqsave();
7474.898971: funcgraph_entry   0.037 us   |                                      select_task_rq_rt();
7474.898971: funcgraph_entry              |                                      native_smp_send_reschedule() {
7474.898972: funcgraph_entry              |                                        physflat_send_IPI_mask() {
7474.898972: funcgraph_entry   0.181 us   |                                          default_send_IPI_mask_sequence_phys();
7474.898972: funcgraph_exit:   0.421 us   |                                        }
7474.898972: funcgraph_exit:   0.677 us   |                                      }
7474.898972: funcgraph_entry   0.158 us   |                                      ttwu_stat();
7474.898973: funcgraph_entry   0.033 us   |                                      _raw_spin_unlock_irqrestore();
7474.898973: funcgraph_exit:   2.784 us   |                                    }
7474.898973: funcgraph_exit:   3.022 us   |                                  }
7474.898973: funcgraph_exit:   3.398 us   |                                }
7474.898973: funcgraph_exit:   3.616 us   |                              }
7474.898973: funcgraph_entry   0.033 us   |                              _raw_spin_unlock_irqrestore();
7474.898974: funcgraph_exit:   4.634 us   |                            }
7474.898974: funcgraph_exit:   4.948 us   |                          }
7474.898974: funcgraph_entry   0.033 us   |                          _raw_spin_unlock_irqrestore();
7474.898975: funcgraph_exit:   6.420 us   |                        }
7474.898975: funcgraph_exit:   6.765 us   |                      }
7474.898975: funcgraph_exit:   7.743 us   |                    }
7474.898975: funcgraph_exit:   8.029 us   |                  }
7474.898975: funcgraph_exit: + 12.542 us  |                }
7474.898976: funcgraph_exit: + 12.838 us  |              }
7474.898976: funcgraph_exit: + 14.130 us  |            }
7474.898976: funcgraph_exit: + 15.069 us  |          }
7474.898976: funcgraph_exit: + 15.355 us  |        }
7474.898976: funcgraph_exit: + 15.959 us  |      }
7474.898976: funcgraph_exit: + 16.244 us  |    }
7474.898976: funcgraph_exit: + 26.284 us  |  }

And here is an example from 3.4 for comparison:

342680.275804: funcgraph_entry              |  ip_rcv_finish() {
342680.275805: funcgraph_entry              |    ip_route_input_common() {
342680.275806: funcgraph_entry   0.044 us   |      ipv4_validate_peer();
342680.275806: funcgraph_entry   0.033 us   |      skb_dst_set_noref();
342680.275807: funcgraph_exit:   1.249 us   |    }
342680.275807: funcgraph_entry              |    ip_local_deliver() {
342680.275807: funcgraph_entry              |      ip_local_deliver_finish() {
342680.275807: funcgraph_entry   0.037 us   |        raw_local_deliver();
342680.275807: funcgraph_entry              |        udp_rcv() {
342680.275808: funcgraph_entry              |          __udp4_lib_rcv() {
342680.275808: funcgraph_entry              |            __pskb_pull_tail() {
342680.275808: funcgraph_entry   0.085 us   |              skb_copy_bits();
342680.275808: funcgraph_exit:   0.416 us   |            }
342680.275808: funcgraph_entry              |            __udp4_lib_mcast_deliver() {
342680.275809: funcgraph_entry   0.058 us   |              _raw_spin_lock();
342680.275809: funcgraph_entry   0.044 us   |              ip_mc_sf_allow();
342680.275809: funcgraph_entry              |              flush_stack() {
342680.275810: funcgraph_entry              |                udp_queue_rcv_skb() {
342680.275810: funcgraph_entry   0.030 us   |                  ipv4_pktinfo_prepare();
342680.275810: funcgraph_entry   0.030 us   |                  _raw_spin_lock();
342680.275811: funcgraph_entry              |                  __udp_queue_rcv_skb() {
342680.275811: funcgraph_entry              |                    sock_queue_rcv_skb() {
342680.275811: funcgraph_entry   0.046 us   |                      sk_filter();
342680.275811: funcgraph_entry   0.031 us   |                      _raw_spin_lock_irqsave();
342680.275811: funcgraph_entry   0.035 us   |                      _raw_spin_unlock_irqrestore();
342680.275812: funcgraph_entry              |                      sock_def_readable() {
342680.275812: funcgraph_entry              |                        __wake_up_sync_key() {
342680.275812: funcgraph_entry   0.088 us   |                          _raw_spin_lock_irqsave();
342680.275812: funcgraph_entry              |                          __wake_up_common() {
342680.275813: funcgraph_entry              |                            ep_poll_callback() {
342680.275813: funcgraph_entry   0.143 us   |                              _raw_spin_lock_irqsave();
342680.275813: funcgraph_entry              |                              __wake_up_locked() {
342680.275814: funcgraph_entry              |                                __wake_up_common() {
342680.275814: funcgraph_entry              |                                  default_wake_function() {
342680.275814: funcgraph_entry              |                                    try_to_wake_up() {
342680.275814: funcgraph_entry   0.103 us   |                                      _raw_spin_lock_irqsave();
342680.275815: funcgraph_entry   0.039 us   |                                      select_task_rq_rt();
342680.275815: funcgraph_entry              |                                      native_smp_send_reschedule() {
342680.275815: funcgraph_entry              |                                        physflat_send_IPI_mask() {
342680.275815: funcgraph_entry   0.122 us   |                                          default_send_IPI_mask_sequence_phys();
342680.275816: funcgraph_exit:   0.369 us   |                                        }
342680.275816: funcgraph_exit:   0.624 us   |                                      }
342680.275816: funcgraph_entry   0.117 us   |                                      ttwu_stat();
342680.275816: funcgraph_entry   0.040 us   |                                      _raw_spin_unlock_irqrestore();
342680.275817: funcgraph_exit:   2.529 us   |                                    }
342680.275817: funcgraph_exit:   2.763 us   |                                  }
342680.275817: funcgraph_exit:   3.121 us   |                                }
342680.275817: funcgraph_exit:   3.348 us   |                              }
342680.275817: funcgraph_entry   0.036 us   |                              _raw_spin_unlock_irqrestore();
342680.275817: funcgraph_exit:   4.422 us   |                            }
342680.275817: funcgraph_exit:   4.818 us   |                          }
342680.275817: funcgraph_entry   0.036 us   |                          _raw_spin_unlock_irqrestore();
342680.275818: funcgraph_exit:   5.666 us   |                        }
342680.275818: funcgraph_exit:   6.051 us   |                      }
342680.275818: funcgraph_exit:   7.076 us   |                    }
342680.275818: funcgraph_exit:   7.363 us   |                  }
342680.275818: funcgraph_exit:   8.333 us   |                }
342680.275818: funcgraph_exit:   8.613 us   |              }
342680.275818: funcgraph_exit:   9.838 us   |            }
342680.275818: funcgraph_exit: + 10.800 us  |          }
342680.275819: funcgraph_exit: + 11.034 us  |        }
342680.275819: funcgraph_exit: + 11.628 us  |      }
342680.275819: funcgraph_exit: + 11.965 us  |    }
342680.275819: funcgraph_exit: + 13.932 us  |  }

Now while it does appear that ip_check_mc_rcu() and
ipv4_pktinfo_prepare() may have added some latency in the receive path
there may be something else going on here as well.  Obviously even the
13us difference in ip_rcv_finish() doesn't fully explain the large
spikes of one-way latency that I'm seeing though my theory is that the
additional packet overhead may add up during a large burst of packets.
Any input on this problem would be appreciated.

Thanks,
Shawn

-- 

---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.

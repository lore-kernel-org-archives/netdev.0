From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: ipv6: handle -EFAULT from skb_copy_bits
Date: Mon, 19 Dec 2016 12:03:20 -0500
Message-ID: <20161219170320.nnezhql2vj5mrrrp@codemonkey.org.uk>
References: <20161214154729.g4yg4mxcgkvpe5w7@codemonkey.org.uk>
 <20161217.104120.945262627572958024.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arcturus.aphlor.org ([188.246.204.175]:46578 "EHLO
        arcturus.aphlor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1763890AbcLSRDY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2016 12:03:24 -0500
Content-Disposition: inline
In-Reply-To: <20161217.104120.945262627572958024.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 17, 2016 at 10:41:20AM -0500, David Miller wrote:

 > > It seems to be possible to craft a packet for sendmsg that triggers
 > > the -EFAULT path in skb_copy_bits resulting in a BUG_ON that looks like:
 > > 
 > > RIP: 0010:[<ffffffff817c6390>] [<ffffffff817c6390>] rawv6_sendmsg+0xc30/0xc40
 > > RSP: 0018:ffff881f6c4a7c18  EFLAGS: 00010282
 > > RAX: 00000000fffffff2 RBX: ffff881f6c681680 RCX: 0000000000000002
 > > RDX: ffff881f6c4a7cf8 RSI: 0000000000000030 RDI: ffff881fed0f6a00
 > > RBP: ffff881f6c4a7da8 R08: 0000000000000000 R09: 0000000000000009
 > > R10: ffff881fed0f6a00 R11: 0000000000000009 R12: 0000000000000030
 > > R13: ffff881fed0f6a00 R14: ffff881fee39ba00 R15: ffff881fefa93a80
 > > 
 > > Call Trace:
 > >  [<ffffffff8118ba23>] ? unmap_page_range+0x693/0x830
 > >  [<ffffffff81772697>] inet_sendmsg+0x67/0xa0
 > >  [<ffffffff816d93f8>] sock_sendmsg+0x38/0x50
 > >  [<ffffffff816d982f>] SYSC_sendto+0xef/0x170
 > >  [<ffffffff816da27e>] SyS_sendto+0xe/0x10
 > >  [<ffffffff81002910>] do_syscall_64+0x50/0xa0
 > >  [<ffffffff817f7cbc>] entry_SYSCALL64_slow_path+0x25/0x25
 > > 
 > > Handle this in rawv6_push_pending_frames and jump to the failure path.
 > > 
 > > Signed-off-by: Dave Jones <davej@codemonkey.org.uk>
 > 
 > Hmmm, that's interesting.  Becaue the code in __ip6_append_data(), which
 > sets up the ->cork.base.length value, seems to be defensively trying to
 > avoid this possibility.
 > 
 > For example, it checks things like:
 > 
 > 	if (cork->length + length > mtu - headersize && ipc6->dontfrag &&
 > 	    (sk->sk_protocol == IPPROTO_UDP ||
 > 	     sk->sk_protocol == IPPROTO_RAW)) {
 > 
 > This is why the transport offset plus the length should never exceed
 > the total length for that skb_copy_bits() call.
 > 
 > Perhaps this protocol check in the code above is incomplete?  Do you
 > know what the sk->sk_protocol value was when that BUG triggered?  That
 > might shine some light on what is really happening here.

Hm.
  sk_protocol = 7, 






struct sock {
  __sk_common = {
    {
      skc_addrpair = 0, 
      {
        skc_daddr = 0, 
        skc_rcv_saddr = 0
      }
    }, 
    {
      skc_hash = 0, 
      skc_u16hashes = {0, 0}
    }, 
    {
      skc_portpair = 458752, 
      {
        skc_dport = 0, 
        skc_num = 7
      }
    }, 
    skc_family = 10, 
    skc_state = 7 '\a', 
    skc_reuse = 1 '\001', 
    skc_reuseport = 0 '\000', 
    skc_ipv6only = 0 '\000', 
    skc_net_refcnt = 1 '\001', 
    skc_bound_dev_if = 0, 
    {
      skc_bind_node = {
        next = 0x0, 
        pprev = 0x0
      }, 
      skc_portaddr_node = {
        next = 0x0, 
        pprev = 0x0
      }
    }, 
    skc_prot = 0xffffffff81cf3bc0 <rawv6_prot>, 
    skc_net = {
      net = 0xffffffff81ce78c0 <init_net>
    }, 
    skc_v6_daddr = {
      in6_u = {
        u6_addr8 = "\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000", 
        u6_addr16 = {0, 0, 0, 0, 0, 0, 0, 0}, 
        u6_addr32 = {0, 0, 0, 0}
      }
    }, 
    }, 
    skc_v6_rcv_saddr = {
      in6_u = {
        u6_addr8 = "\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000", 
        u6_addr16 = {0, 0, 0, 0, 0, 0, 0, 0}, 
        u6_addr32 = {0, 0, 0, 0}
      }
    }, 
    skc_cookie = {
      counter = 0
    }, 
    {
      skc_flags = 256, 
      skc_listener = 0x100, 
      skc_tw_dr = 0x100
    }, 
    skc_dontcopy_begin = 0xffff881fd1ce9b68, 
    {
      skc_node = {
        next = 0x0, 
        pprev = 0x0
      }, 
      skc_nulls_node = {
        next = 0x0, 
        pprev = 0x0
      }
    }, 
    skc_tx_queue_mapping = -1, 
    {
      skc_incoming_cpu = -1, 
      skc_rcv_wnd = 4294967295, 
      skc_tw_rcv_nxt = 4294967295
    }, 
    skc_refcnt = {
      counter = 1
    }, 
    skc_dontcopy_end = 0xffff881fd1ce9b84, 
    {
      skc_rxhash = 0, 
      skc_window_clamp = 0, 
      skc_tw_snd_nxt = 0
    }
  }, 
  sk_lock = {
    slock = {
      {
        rlock = {
          raw_lock = {
            val = {
              counter = 0
            }
          }
        }
      }
    }, 
    owned = 1, 
    wq = {
      lock = {
        {
          rlock = {
            raw_lock = {
              val = {
                counter = 0
              }
            }
          }
        }
      }, 
      task_list = {
        next = 0xffff881fd1ce9b98, 
        prev = 0xffff881fd1ce9b98
      }
    }
  }, 
  sk_receive_queue = {
    next = 0xffff881fd1ce9ba8, 
    prev = 0xffff881fd1ce9ba8, 
    qlen = 0, 
    lock = {
      {
        rlock = {
          raw_lock = {
            val = {
              counter = 0
            }
          }
        }
      }
    }
  }, 
  sk_backlog = {
    rmem_alloc = {
      counter = 0
    }, 
    len = 0, 
    head = 0x0, 
    tail = 0x0
  }, 
  sk_forward_alloc = 0, 
  sk_txhash = 0, 
  sk_napi_id = 0, 
  sk_ll_usec = 0, 
  sk_drops = {
    counter = 0
  }, 
  sk_rcvbuf = 1024000, 
  sk_filter = 0x0, 
  {
    sk_wq = 0xffff881fc4b3ab00, 
    sk_wq_raw = 0xffff881fc4b3ab00
  }, 
  sk_policy = {0x0, 0x0}, 
  sk_rx_dst = 0x0, 
  sk_dst_cache = 0x0, 
  sk_wmem_alloc = {
    counter = 769
  }, 
  sk_omem_alloc = {
    counter = 640
  }, 
  sk_sndbuf = 212992, 
  sk_write_queue = {
    next = 0xffff881f6fc60b00, 
    prev = 0xffff881f6fc60b00, 
    qlen = 1, 
    lock = {
      {
        rlock = {
          raw_lock = {
            val = {
              counter = 0
            }
          }
        }
      }
    }
  }, 
  sk_shutdown = 0, 
  sk_no_check_tx = 0, 
  sk_no_check_rx = 0, 
  sk_userlocks = 0, 
  sk_protocol = 7, 
  sk_type = 3, 
  sk_wmem_queued = 0, 
  sk_allocation = 37748928, 
  sk_pacing_rate = 4294967295, 
  sk_max_pacing_rate = 4294967295, 
  sk_route_caps = 0, 
  sk_route_nocaps = 0, 
  sk_gso_type = 0, 
  sk_gso_max_size = 0, 
  sk_gso_max_segs = 0, 
  sk_rcvlowat = 1, 
  sk_lingertime = 0, 
  sk_error_queue = {
    next = 0xffff881fd1ce9c88, 
    prev = 0xffff881fd1ce9c88, 
    qlen = 0, 
    lock = {
      {
        rlock = {
          raw_lock = {
            val = {
              counter = 0
            }
          }
        }
      }
    }
  }, 
  sk_prot_creator = 0xffffffff81cf3bc0 <rawv6_prot>, 
  sk_callback_lock = {
    raw_lock = {
      cnts = {
        counter = 0
      }, 
      wait_lock = {
        val = {
          counter = 0
        }
      }
    }
  }, 
  sk_err = 0, 
  sk_err_soft = 0, 
  sk_ack_backlog = 0, 
  sk_max_ack_backlog = 0, 
  sk_priority = 0, 
  sk_mark = 0, 
  sk_peer_pid = 0x0, 
  sk_peer_cred = 0x0, 
  sk_rcvtimeo = 9223372036854775807, 
  sk_sndtimeo = 9223372036854775807, 
  sk_timer = {
    entry = {
      next = 0x0, 
      pprev = 0x0
    }, 
    expires = 0, 
    function = 0x0, 
    data = 0, 
    flags = 4, 
    slack = -1, 
    start_pid = -1, 
    start_site = 0x0, 
    start_comm = "\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"
  }, 
  sk_stamp = {
    tv64 = 1481510503238183349
  }, 
  sk_tsflags = 0, 
  sk_tskey = 0, 
  sk_socket = 0xffff881fd0d24b00, 
  sk_user_data = 0x0, 
  sk_frag = {
    page = 0x0, 
    offset = 0, 
    size = 0
  }, 
  sk_send_head = 0x0, 
  sk_peek_off = -1, 
  sk_write_pending = 0, 
  sk_security = 0x0, 
  sk_cgrp_data = {
    {
      {
        is_data = 48 '0', 
        padding = 109 'm', 
        prioidx = 33292, 
        classid = 4294967295
      }, 
      val = 18446744071596436784
    }
  }, 
  sk_memcg = 0x0, 
  sk_state_change = 0xffffffff816dbed0 <sock_def_wakeup>, 
  sk_data_ready = 0xffffffff816dcd20 <sock_def_readable>, 
  sk_write_space = 0xffffffff816dcc90 <sock_def_write_space>, 
  sk_error_report = 0xffffffff816dcc30 <sock_def_error_report>, 
  sk_backlog_rcv = 0xffffffff817c5690 <rawv6_rcv_skb>, 
  sk_destruct = 0xffffffff81772460 <inet_sock_destruct>, 
  sk_reuseport_cb = 0x0
}

From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [REGRESSION] NFS is creating a hidden port (left over from
 xs_bind() )
Date: Fri, 19 Jun 2015 12:25:53 -0400
Message-ID: <20150619122553.43d2d86c@gandalf.local.home>
References: <20150611234929.7b48d314@gandalf.local.home>
	<CAHQdGtSyHtMfyVxT=hFY4m6XvM=3mxnZ=ajVJWYNXvYqE0+3zA@mail.gmail.com>
	<1434120035.27504.77.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150612113420.5c114183@gandalf.local.home>
	<20150612115038.44e20ccd@gandalf.local.home>
	<20150617230819.0a11e47a@grimm.local.home>
	<CAHQdGtQfF8sgfj6B2H=Sg+mn6ghPD+4UuZMSMFjj3XCVee60pw@mail.gmail.com>
	<20150618154914.57424225@gandalf.local.home>
	<20150618185051.2b2828c3@tlielax.poochiereds.net>
	<20150618210843.4b09c31c@grimm.local.home>
	<20150618213702.33f64b20@synchrony.poochiereds.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/uz8ubrnLjlLeVfoWsN_3=99"
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Anna Schumaker <anna.schumaker@netapp.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Linux Network Devel Mailing List <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>, bfields@fieldses.org
To: Jeff Layton <jlayton@poochiereds.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0109.hostedemail.com ([216.40.44.109]:59970 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752130AbbFSQ0B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2015 12:26:01 -0400
In-Reply-To: <20150618213702.33f64b20@synchrony.poochiereds.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--MP_/uz8ubrnLjlLeVfoWsN_3=99
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Thu, 18 Jun 2015 21:37:02 -0400
Jeff Layton <jlayton@poochiereds.net> wrote:

> > Note, the box has been rebooted since I posted my last trace.
> > 
> 
> Ahh pity. The port has probably changed...if you trace it again maybe
> try to figure out what it's talking to before rebooting the server?
> 

OK, I ran it again. Here's exactly what I did:

I reverted my revert and applied the attached patch.

I built and rebooted the box (with the same config) an then I waited
till I saw the kworker in my trace:

 # grep kworker /debug/tracing/trace

Once I found it, I noted the port that it bounded to.

    kworker/1:1H-131   [001] ..s.   149.230212: inet_csk_get_port: kworker/1:1H:131 got port 947


Note, unhide-tcp didn't show any issues.

I saved the rpcinfo of both my box and my wifes box:

# rpcinfo -p localhost 
   program vers proto   port  service
    100000    4   tcp    111  portmapper
    100000    3   tcp    111  portmapper
    100000    2   tcp    111  portmapper
    100000    4   udp    111  portmapper
    100000    3   udp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  33043  status
    100024    1   tcp  53880  status
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100003    4   tcp   2049  nfs
    100227    2   tcp   2049
    100227    3   tcp   2049
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    4   udp   2049  nfs
    100227    2   udp   2049
    100227    3   udp   2049
    100021    1   udp  39455  nlockmgr
    100021    3   udp  39455  nlockmgr
    100021    4   udp  39455  nlockmgr
    100021    1   tcp  48916  nlockmgr
    100021    3   tcp  48916  nlockmgr
    100021    4   tcp  48916  nlockmgr
    100005    1   udp  58465  mountd
    100005    1   tcp  56391  mountd
    100005    2   udp  35741  mountd
    100005    2   tcp  40520  mountd
    100005    3   udp  56522  mountd
    100005    3   tcp  33464  mountd

# rpcinfo -p wife
   program vers proto   port  service
    100000    4   tcp    111  portmapper
    100000    3   tcp    111  portmapper
    100000    2   tcp    111  portmapper
    100000    4   udp    111  portmapper
    100000    3   udp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  34243  status
    100024    1   tcp  34498  status

and ran:

while :; do  netstat -tapn |grep 947; sleep 1; done

Waited for the state to turn from ESTABLISHED to TIME_WAIT, and then I
ran the rpcinfo again, but they didn't change. I checked for hidden
ports, but none were listed (yet).

I then waited for the port to disappear. I ran the rpcinfo again, but
it still didn't change. But unhide-tpc reports:

  Found Hidden port that not appears in ss: 947


Here's that trace:

# tracer: nop
#
# entries-in-buffer/entries-written: 1978/1978   #P:4
#
#                              _-----=> irqs-off
#                             / _----=> need-resched
#                            | / _---=> hardirq/softirq
#                            || / _--=> preempt-depth
#                            ||| /     delay
#           TASK-PID   CPU#  ||||    TIMESTAMP  FUNCTION
#              | |       |   ||||       |         |
        modprobe-1904  [002] ....    22.119972: rpc_init_mempool: RPC:       creating workqueue rpciod
           mount-1912  [002] ....    22.305981: rpc_fill_super: RPC:       sending pipefs MOUNT notification for net ffffffff818b9780 (init_net)
        rpc.nfsd-4720  [001] ....    50.855600: xs_local_setup_socket: RPC:       worker connecting xprt ffff880407939800 via AF_LOCAL to /var/run/rpcbind.sock
        rpc.nfsd-4720  [001] ....    50.855609: xs_local_setup_socket: RPC:       xprt ffff880407939800 connected to /var/run/rpcbind.sock
        rpc.nfsd-4720  [001] ....    50.855610: xs_setup_local: RPC:       set up xprt to /var/run/rpcbind.sock via AF_LOCAL
        rpc.nfsd-4720  [001] ....    50.855614: xprt_create_transport: RPC:       created transport ffff880407939800 with 65536 slots
        rpc.nfsd-4720  [001] ....    50.855614: rpc_new_client: RPC:       creating rpcbind client for localhost (xprt ffff880407939800)
        rpc.nfsd-4720  [001] ....    50.855625: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.855626: rpc_new_task: RPC:       allocated task ffff88040a645e00
        rpc.nfsd-4720  [001] ....    50.855627: __rpc_execute: RPC:     1 __rpc_execute flags=0x680
        rpc.nfsd-4720  [001] ....    50.855628: call_start: RPC:     1 call_start rpcbind2 proc NULL (sync)
        rpc.nfsd-4720  [001] ....    50.855628: call_reserve: RPC:     1 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.855629: xprt_alloc_slot: RPC:     1 reserved req ffff880403542200 xid 3a45b0ec
        rpc.nfsd-4720  [001] ....    50.855629: call_reserveresult: RPC:     1 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.855630: call_refresh: RPC:     1 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.855631: call_refreshresult: RPC:     1 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.855631: call_allocate: RPC:     1 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.855632: rpc_malloc: RPC:     1 allocated buffer of size 96 at ffff8804045aa000
        rpc.nfsd-4720  [001] ....    50.855633: call_bind: RPC:     1 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.855633: call_connect: RPC:     1 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.855634: call_transmit: RPC:     1 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.855634: xprt_prepare_transmit: RPC:     1 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.855635: call_transmit: RPC:     1 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.855635: xprt_transmit: RPC:     1 xprt_transmit(44)
        rpc.nfsd-4720  [001] ....    50.855638: xs_local_send_request: RPC:       xs_local_send_request(44) = 0
        rpc.nfsd-4720  [001] ....    50.855638: xprt_transmit: RPC:     1 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.855639: __rpc_sleep_on_priority: RPC:     1 sleep_on(queue "xprt_pending" time 4294904942)
        rpc.nfsd-4720  [001] ..s.    50.855640: __rpc_sleep_on_priority: RPC:     1 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.855640: __rpc_sleep_on_priority: RPC:     1 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.855641: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.855642: __rpc_execute: RPC:     1 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.855723: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.855725: xprt_complete_rqst: RPC:     1 xid 3a45b0ec complete (24 bytes received)
         rpcbind-1871  [003] ..s.    50.855726: rpc_wake_up_task_queue_locked: RPC:     1 __rpc_wake_up_task (now 4294904942)
         rpcbind-1871  [003] ..s.    50.855726: rpc_wake_up_task_queue_locked: RPC:     1 disabling timer
         rpcbind-1871  [003] ..s.    50.855727: rpc_wake_up_task_queue_locked: RPC:     1 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.855729: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.855768: __rpc_execute: RPC:     1 sync task resuming
        rpc.nfsd-4720  [001] ....    50.855770: call_status: RPC:     1 call_status (status 24)
        rpc.nfsd-4720  [001] ....    50.855771: call_decode: RPC:     1 call_decode (status 24)
        rpc.nfsd-4720  [001] ....    50.855773: call_decode: RPC:     1 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.855774: __rpc_execute: RPC:     1 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.855774: __rpc_execute: RPC:     1 release task
        rpc.nfsd-4720  [001] ....    50.855776: rpc_free: RPC:       freeing buffer of size 96 at ffff8804045aa000
        rpc.nfsd-4720  [001] ....    50.855777: xprt_release: RPC:     1 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.855778: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.855779: rpc_release_client: RPC:       rpc_release_client(ffff8800d8e62c00)
        rpc.nfsd-4720  [001] ....    50.855781: rpc_free_task: RPC:     1 freeing task
        rpc.nfsd-4720  [001] ....    50.855782: rpc_new_client: RPC:       creating rpcbind client for localhost (xprt ffff880407939800)
        rpc.nfsd-4720  [001] ....    50.855795: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.855796: rpc_new_task: RPC:       allocated task ffff88040a645e00
        rpc.nfsd-4720  [001] ....    50.855797: __rpc_execute: RPC:     2 __rpc_execute flags=0x680
        rpc.nfsd-4720  [001] ....    50.855798: call_start: RPC:     2 call_start rpcbind4 proc NULL (sync)
        rpc.nfsd-4720  [001] ....    50.855799: call_reserve: RPC:     2 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.855800: xprt_alloc_slot: RPC:     2 reserved req ffff880403542200 xid 3b45b0ec
        rpc.nfsd-4720  [001] ....    50.855801: call_reserveresult: RPC:     2 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.855801: call_refresh: RPC:     2 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.855802: call_refreshresult: RPC:     2 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.855803: call_allocate: RPC:     2 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.855804: rpc_malloc: RPC:     2 allocated buffer of size 96 at ffff8804045aa000
        rpc.nfsd-4720  [001] ....    50.855805: call_bind: RPC:     2 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.855806: call_connect: RPC:     2 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.855806: call_transmit: RPC:     2 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.855807: xprt_prepare_transmit: RPC:     2 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.855808: call_transmit: RPC:     2 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.855808: xprt_transmit: RPC:     2 xprt_transmit(44)
        rpc.nfsd-4720  [001] ....    50.855817: xs_local_send_request: RPC:       xs_local_send_request(44) = 0
        rpc.nfsd-4720  [001] ....    50.855817: xprt_transmit: RPC:     2 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.855818: __rpc_sleep_on_priority: RPC:     2 sleep_on(queue "xprt_pending" time 4294904942)
        rpc.nfsd-4720  [001] ..s.    50.855819: __rpc_sleep_on_priority: RPC:     2 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.855820: __rpc_sleep_on_priority: RPC:     2 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.855822: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.855822: __rpc_execute: RPC:     2 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.855866: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.855868: xprt_complete_rqst: RPC:     2 xid 3b45b0ec complete (24 bytes received)
         rpcbind-1871  [003] ..s.    50.855869: rpc_wake_up_task_queue_locked: RPC:     2 __rpc_wake_up_task (now 4294904942)
         rpcbind-1871  [003] ..s.    50.855870: rpc_wake_up_task_queue_locked: RPC:     2 disabling timer
         rpcbind-1871  [003] ..s.    50.855871: rpc_wake_up_task_queue_locked: RPC:     2 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.855875: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.855910: __rpc_execute: RPC:     2 sync task resuming
        rpc.nfsd-4720  [001] ....    50.855911: call_status: RPC:     2 call_status (status 24)
        rpc.nfsd-4720  [001] ....    50.855912: call_decode: RPC:     2 call_decode (status 24)
        rpc.nfsd-4720  [001] ....    50.855914: call_decode: RPC:     2 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.855914: __rpc_execute: RPC:     2 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.855915: __rpc_execute: RPC:     2 release task
        rpc.nfsd-4720  [001] ....    50.855916: rpc_free: RPC:       freeing buffer of size 96 at ffff8804045aa000
        rpc.nfsd-4720  [001] ....    50.855917: xprt_release: RPC:     2 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.855918: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.855919: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.855920: rpc_free_task: RPC:     2 freeing task
        rpc.nfsd-4720  [001] ....    50.855922: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.855923: rpc_new_task: RPC:       allocated task ffff88040a645e00
        rpc.nfsd-4720  [001] ....    50.855924: __rpc_execute: RPC:     3 __rpc_execute flags=0x2280
        rpc.nfsd-4720  [001] ....    50.855925: call_start: RPC:     3 call_start rpcbind4 proc UNSET (sync)
        rpc.nfsd-4720  [001] ....    50.855926: call_reserve: RPC:     3 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.855927: xprt_alloc_slot: RPC:     3 reserved req ffff880403542200 xid 3c45b0ec
        rpc.nfsd-4720  [001] ....    50.855927: call_reserveresult: RPC:     3 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.855928: call_refresh: RPC:     3 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.855929: call_refreshresult: RPC:     3 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.855930: call_allocate: RPC:     3 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.855931: rpc_malloc: RPC:     3 allocated buffer of size 188 at ffff8804045aa000
        rpc.nfsd-4720  [001] ....    50.855932: call_bind: RPC:     3 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.855933: call_connect: RPC:     3 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.855934: call_transmit: RPC:     3 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.855934: xprt_prepare_transmit: RPC:     3 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.855935: call_transmit: RPC:     3 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.855938: xprt_transmit: RPC:     3 xprt_transmit(68)
        rpc.nfsd-4720  [001] ....    50.855945: xs_local_send_request: RPC:       xs_local_send_request(68) = 0
        rpc.nfsd-4720  [001] ....    50.855946: xprt_transmit: RPC:     3 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.855947: __rpc_sleep_on_priority: RPC:     3 sleep_on(queue "xprt_pending" time 4294904942)
        rpc.nfsd-4720  [001] ..s.    50.855948: __rpc_sleep_on_priority: RPC:     3 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.855948: __rpc_sleep_on_priority: RPC:     3 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.855950: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.855951: __rpc_execute: RPC:     3 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.856003: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.856005: xprt_complete_rqst: RPC:     3 xid 3c45b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.856006: rpc_wake_up_task_queue_locked: RPC:     3 __rpc_wake_up_task (now 4294904942)
         rpcbind-1871  [003] ..s.    50.856007: rpc_wake_up_task_queue_locked: RPC:     3 disabling timer
         rpcbind-1871  [003] ..s.    50.856008: rpc_wake_up_task_queue_locked: RPC:     3 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.856011: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.856046: __rpc_execute: RPC:     3 sync task resuming
        rpc.nfsd-4720  [001] ....    50.856048: call_status: RPC:     3 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.856049: call_decode: RPC:     3 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.856050: call_decode: RPC:     3 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.856051: __rpc_execute: RPC:     3 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.856052: __rpc_execute: RPC:     3 release task
        rpc.nfsd-4720  [001] ....    50.856053: rpc_free: RPC:       freeing buffer of size 188 at ffff8804045aa000
        rpc.nfsd-4720  [001] ....    50.856054: xprt_release: RPC:     3 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.856055: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.856055: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.856056: rpc_free_task: RPC:     3 freeing task
        rpc.nfsd-4720  [001] ....    50.856058: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.856059: rpc_new_task: RPC:       allocated task ffff88040a645e00
        rpc.nfsd-4720  [001] ....    50.856060: __rpc_execute: RPC:     4 __rpc_execute flags=0x2280
        rpc.nfsd-4720  [001] ....    50.856061: call_start: RPC:     4 call_start rpcbind4 proc UNSET (sync)
        rpc.nfsd-4720  [001] ....    50.856062: call_reserve: RPC:     4 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.856063: xprt_alloc_slot: RPC:     4 reserved req ffff880403542200 xid 3d45b0ec
        rpc.nfsd-4720  [001] ....    50.856063: call_reserveresult: RPC:     4 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.856064: call_refresh: RPC:     4 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.856065: call_refreshresult: RPC:     4 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.856066: call_allocate: RPC:     4 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.856067: rpc_malloc: RPC:     4 allocated buffer of size 188 at ffff8804045aa000
        rpc.nfsd-4720  [001] ....    50.856067: call_bind: RPC:     4 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.856068: call_connect: RPC:     4 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.856069: call_transmit: RPC:     4 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.856069: xprt_prepare_transmit: RPC:     4 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.856070: call_transmit: RPC:     4 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.856072: xprt_transmit: RPC:     4 xprt_transmit(68)
        rpc.nfsd-4720  [001] ....    50.856079: xs_local_send_request: RPC:       xs_local_send_request(68) = 0
        rpc.nfsd-4720  [001] ....    50.856080: xprt_transmit: RPC:     4 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.856081: __rpc_sleep_on_priority: RPC:     4 sleep_on(queue "xprt_pending" time 4294904942)
        rpc.nfsd-4720  [001] ..s.    50.856081: __rpc_sleep_on_priority: RPC:     4 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.856082: __rpc_sleep_on_priority: RPC:     4 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.856084: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.856084: __rpc_execute: RPC:     4 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.856139: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.856142: xprt_complete_rqst: RPC:     4 xid 3d45b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.856143: rpc_wake_up_task_queue_locked: RPC:     4 __rpc_wake_up_task (now 4294904942)
         rpcbind-1871  [003] ..s.    50.856143: rpc_wake_up_task_queue_locked: RPC:     4 disabling timer
         rpcbind-1871  [003] ..s.    50.856145: rpc_wake_up_task_queue_locked: RPC:     4 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.856148: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.856186: __rpc_execute: RPC:     4 sync task resuming
        rpc.nfsd-4720  [001] ....    50.856188: call_status: RPC:     4 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.856189: call_decode: RPC:     4 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.856190: call_decode: RPC:     4 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.856191: __rpc_execute: RPC:     4 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.856192: __rpc_execute: RPC:     4 release task
        rpc.nfsd-4720  [001] ....    50.856193: rpc_free: RPC:       freeing buffer of size 188 at ffff8804045aa000
        rpc.nfsd-4720  [001] ....    50.856194: xprt_release: RPC:     4 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.856195: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.856196: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.856196: rpc_free_task: RPC:     4 freeing task
        rpc.nfsd-4720  [001] ....    50.856198: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.856199: rpc_new_task: RPC:       allocated task ffff88040a645e00
        rpc.nfsd-4720  [001] ....    50.856200: __rpc_execute: RPC:     5 __rpc_execute flags=0x2280
        rpc.nfsd-4720  [001] ....    50.856201: call_start: RPC:     5 call_start rpcbind4 proc UNSET (sync)
        rpc.nfsd-4720  [001] ....    50.856202: call_reserve: RPC:     5 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.856202: xprt_alloc_slot: RPC:     5 reserved req ffff880403542200 xid 3e45b0ec
        rpc.nfsd-4720  [001] ....    50.856203: call_reserveresult: RPC:     5 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.856204: call_refresh: RPC:     5 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.856205: call_refreshresult: RPC:     5 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.856206: call_allocate: RPC:     5 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.856207: rpc_malloc: RPC:     5 allocated buffer of size 188 at ffff8804045aa000
        rpc.nfsd-4720  [001] ....    50.856207: call_bind: RPC:     5 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.856208: call_connect: RPC:     5 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.856209: call_transmit: RPC:     5 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.856209: xprt_prepare_transmit: RPC:     5 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.856210: call_transmit: RPC:     5 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.856212: xprt_transmit: RPC:     5 xprt_transmit(68)
        rpc.nfsd-4720  [001] ....    50.856219: xs_local_send_request: RPC:       xs_local_send_request(68) = 0
        rpc.nfsd-4720  [001] ....    50.856219: xprt_transmit: RPC:     5 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.856221: __rpc_sleep_on_priority: RPC:     5 sleep_on(queue "xprt_pending" time 4294904942)
        rpc.nfsd-4720  [001] ..s.    50.856221: __rpc_sleep_on_priority: RPC:     5 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.856222: __rpc_sleep_on_priority: RPC:     5 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.856224: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.856224: __rpc_execute: RPC:     5 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.856277: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.856279: xprt_complete_rqst: RPC:     5 xid 3e45b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.856280: rpc_wake_up_task_queue_locked: RPC:     5 __rpc_wake_up_task (now 4294904942)
         rpcbind-1871  [003] ..s.    50.856281: rpc_wake_up_task_queue_locked: RPC:     5 disabling timer
         rpcbind-1871  [003] ..s.    50.856282: rpc_wake_up_task_queue_locked: RPC:     5 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.856285: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.856321: __rpc_execute: RPC:     5 sync task resuming
        rpc.nfsd-4720  [001] ....    50.856322: call_status: RPC:     5 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.856323: call_decode: RPC:     5 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.856325: call_decode: RPC:     5 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.856326: __rpc_execute: RPC:     5 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.856326: __rpc_execute: RPC:     5 release task
        rpc.nfsd-4720  [001] ....    50.856327: rpc_free: RPC:       freeing buffer of size 188 at ffff8804045aa000
        rpc.nfsd-4720  [001] ....    50.856328: xprt_release: RPC:     5 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.856329: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.856330: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.856331: rpc_free_task: RPC:     5 freeing task
        rpc.nfsd-4720  [001] ....    50.856333: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.856334: rpc_new_task: RPC:       allocated task ffff88040a645e00
        rpc.nfsd-4720  [001] ....    50.856335: __rpc_execute: RPC:     6 __rpc_execute flags=0x2280
        rpc.nfsd-4720  [001] ....    50.856336: call_start: RPC:     6 call_start rpcbind4 proc UNSET (sync)
        rpc.nfsd-4720  [001] ....    50.856337: call_reserve: RPC:     6 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.856337: xprt_alloc_slot: RPC:     6 reserved req ffff880403542200 xid 3f45b0ec
        rpc.nfsd-4720  [001] ....    50.856338: call_reserveresult: RPC:     6 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.856339: call_refresh: RPC:     6 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.856340: call_refreshresult: RPC:     6 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.856341: call_allocate: RPC:     6 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.856342: rpc_malloc: RPC:     6 allocated buffer of size 188 at ffff8804045aa000
        rpc.nfsd-4720  [001] ....    50.856342: call_bind: RPC:     6 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.856343: call_connect: RPC:     6 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.856344: call_transmit: RPC:     6 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.856344: xprt_prepare_transmit: RPC:     6 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.856345: call_transmit: RPC:     6 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.856346: xprt_transmit: RPC:     6 xprt_transmit(68)
        rpc.nfsd-4720  [001] ....    50.856354: xs_local_send_request: RPC:       xs_local_send_request(68) = 0
        rpc.nfsd-4720  [001] ....    50.856354: xprt_transmit: RPC:     6 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.856355: __rpc_sleep_on_priority: RPC:     6 sleep_on(queue "xprt_pending" time 4294904942)
        rpc.nfsd-4720  [001] ..s.    50.856356: __rpc_sleep_on_priority: RPC:     6 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.856357: __rpc_sleep_on_priority: RPC:     6 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.856359: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.856359: __rpc_execute: RPC:     6 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.856409: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.856411: xprt_complete_rqst: RPC:     6 xid 3f45b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.856412: rpc_wake_up_task_queue_locked: RPC:     6 __rpc_wake_up_task (now 4294904942)
         rpcbind-1871  [003] ..s.    50.856413: rpc_wake_up_task_queue_locked: RPC:     6 disabling timer
         rpcbind-1871  [003] ..s.    50.856414: rpc_wake_up_task_queue_locked: RPC:     6 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.856417: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.856453: __rpc_execute: RPC:     6 sync task resuming
        rpc.nfsd-4720  [001] ....    50.856455: call_status: RPC:     6 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.856456: call_decode: RPC:     6 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.856457: call_decode: RPC:     6 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.856458: __rpc_execute: RPC:     6 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.856459: __rpc_execute: RPC:     6 release task
        rpc.nfsd-4720  [001] ....    50.856460: rpc_free: RPC:       freeing buffer of size 188 at ffff8804045aa000
        rpc.nfsd-4720  [001] ....    50.856461: xprt_release: RPC:     6 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.856462: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.856463: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.856464: rpc_free_task: RPC:     6 freeing task
        rpc.nfsd-4720  [001] ....    50.856465: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.856466: rpc_new_task: RPC:       allocated task ffff88040a645e00
        rpc.nfsd-4720  [001] ....    50.856467: __rpc_execute: RPC:     7 __rpc_execute flags=0x2280
        rpc.nfsd-4720  [001] ....    50.856468: call_start: RPC:     7 call_start rpcbind4 proc UNSET (sync)
        rpc.nfsd-4720  [001] ....    50.856469: call_reserve: RPC:     7 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.856470: xprt_alloc_slot: RPC:     7 reserved req ffff880403542200 xid 4045b0ec
        rpc.nfsd-4720  [001] ....    50.856470: call_reserveresult: RPC:     7 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.856471: call_refresh: RPC:     7 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.856472: call_refreshresult: RPC:     7 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.856473: call_allocate: RPC:     7 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.856474: rpc_malloc: RPC:     7 allocated buffer of size 188 at ffff8804045aa000
        rpc.nfsd-4720  [001] ....    50.856474: call_bind: RPC:     7 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.856475: call_connect: RPC:     7 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.856476: call_transmit: RPC:     7 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.856476: xprt_prepare_transmit: RPC:     7 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.856477: call_transmit: RPC:     7 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.856479: xprt_transmit: RPC:     7 xprt_transmit(68)
        rpc.nfsd-4720  [001] ....    50.856486: xs_local_send_request: RPC:       xs_local_send_request(68) = 0
        rpc.nfsd-4720  [001] ....    50.856487: xprt_transmit: RPC:     7 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.856488: __rpc_sleep_on_priority: RPC:     7 sleep_on(queue "xprt_pending" time 4294904942)
        rpc.nfsd-4720  [001] ..s.    50.856489: __rpc_sleep_on_priority: RPC:     7 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.856489: __rpc_sleep_on_priority: RPC:     7 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.856491: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.856492: __rpc_execute: RPC:     7 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.856507: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.856509: xprt_complete_rqst: RPC:     7 xid 4045b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.856510: rpc_wake_up_task_queue_locked: RPC:     7 __rpc_wake_up_task (now 4294904942)
         rpcbind-1871  [003] ..s.    50.856510: rpc_wake_up_task_queue_locked: RPC:     7 disabling timer
         rpcbind-1871  [003] ..s.    50.856511: rpc_wake_up_task_queue_locked: RPC:     7 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.856514: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.856517: __rpc_execute: RPC:     7 sync task resuming
        rpc.nfsd-4720  [001] ....    50.856518: call_status: RPC:     7 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.856519: call_decode: RPC:     7 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.856521: call_decode: RPC:     7 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.856522: __rpc_execute: RPC:     7 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.856522: __rpc_execute: RPC:     7 release task
        rpc.nfsd-4720  [001] ....    50.856523: rpc_free: RPC:       freeing buffer of size 188 at ffff8804045aa000
        rpc.nfsd-4720  [001] ....    50.856524: xprt_release: RPC:     7 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.856525: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.856526: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.856527: rpc_free_task: RPC:     7 freeing task
        rpc.nfsd-4720  [001] ....    50.856530: svc_setup_socket: svc: svc_setup_socket ffff8800db68bac0
        rpc.nfsd-4720  [001] ....    50.856535: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.856536: rpc_new_task: RPC:       allocated task ffff88040a645e00
        rpc.nfsd-4720  [001] ....    50.856536: __rpc_execute: RPC:     8 __rpc_execute flags=0x680
        rpc.nfsd-4720  [001] ....    50.856538: call_start: RPC:     8 call_start rpcbind4 proc SET (sync)
        rpc.nfsd-4720  [001] ....    50.856538: call_reserve: RPC:     8 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.856539: xprt_alloc_slot: RPC:     8 reserved req ffff880403542200 xid 4145b0ec
        rpc.nfsd-4720  [001] ....    50.856540: call_reserveresult: RPC:     8 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.856541: call_refresh: RPC:     8 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.856542: call_refreshresult: RPC:     8 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.856542: call_allocate: RPC:     8 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.856543: rpc_malloc: RPC:     8 allocated buffer of size 188 at ffff8804045aa000
        rpc.nfsd-4720  [001] ....    50.856544: call_bind: RPC:     8 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.856545: call_connect: RPC:     8 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.856545: call_transmit: RPC:     8 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.856546: xprt_prepare_transmit: RPC:     8 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.856547: call_transmit: RPC:     8 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.856548: xprt_transmit: RPC:     8 xprt_transmit(84)
        rpc.nfsd-4720  [001] ....    50.856555: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-4720  [001] ....    50.856555: xprt_transmit: RPC:     8 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.856556: __rpc_sleep_on_priority: RPC:     8 sleep_on(queue "xprt_pending" time 4294904942)
        rpc.nfsd-4720  [001] ..s.    50.856558: __rpc_sleep_on_priority: RPC:     8 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.856558: __rpc_sleep_on_priority: RPC:     8 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.856560: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.856561: __rpc_execute: RPC:     8 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.856580: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.856580: xprt_complete_rqst: RPC:     8 xid 4145b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.856581: rpc_wake_up_task_queue_locked: RPC:     8 __rpc_wake_up_task (now 4294904942)
         rpcbind-1871  [003] ..s.    50.856581: rpc_wake_up_task_queue_locked: RPC:     8 disabling timer
         rpcbind-1871  [003] ..s.    50.856581: rpc_wake_up_task_queue_locked: RPC:     8 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.856582: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.856584: __rpc_execute: RPC:     8 sync task resuming
        rpc.nfsd-4720  [001] ....    50.856584: call_status: RPC:     8 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.856584: call_decode: RPC:     8 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.856585: call_decode: RPC:     8 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.856585: __rpc_execute: RPC:     8 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.856585: __rpc_execute: RPC:     8 release task
        rpc.nfsd-4720  [001] ....    50.856586: rpc_free: RPC:       freeing buffer of size 188 at ffff8804045aa000
        rpc.nfsd-4720  [001] ....    50.856586: xprt_release: RPC:     8 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.856586: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.856586: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.856587: rpc_free_task: RPC:     8 freeing task
        rpc.nfsd-4720  [001] ....    50.856588: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.856588: rpc_new_task: RPC:       allocated task ffff88040a645e00
        rpc.nfsd-4720  [001] ....    50.856588: __rpc_execute: RPC:     9 __rpc_execute flags=0x680
        rpc.nfsd-4720  [001] ....    50.856589: call_start: RPC:     9 call_start rpcbind4 proc SET (sync)
        rpc.nfsd-4720  [001] ....    50.856589: call_reserve: RPC:     9 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.856589: xprt_alloc_slot: RPC:     9 reserved req ffff880403542200 xid 4245b0ec
        rpc.nfsd-4720  [001] ....    50.856590: call_reserveresult: RPC:     9 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.856590: call_refresh: RPC:     9 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.856590: call_refreshresult: RPC:     9 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.856590: call_allocate: RPC:     9 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.856591: rpc_malloc: RPC:     9 allocated buffer of size 188 at ffff8804045aa000
        rpc.nfsd-4720  [001] ....    50.856591: call_bind: RPC:     9 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.856591: call_connect: RPC:     9 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.856592: call_transmit: RPC:     9 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.856592: xprt_prepare_transmit: RPC:     9 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.856592: call_transmit: RPC:     9 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.856593: xprt_transmit: RPC:     9 xprt_transmit(84)
        rpc.nfsd-4720  [001] ....    50.856595: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-4720  [001] ....    50.856595: xprt_transmit: RPC:     9 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.856595: __rpc_sleep_on_priority: RPC:     9 sleep_on(queue "xprt_pending" time 4294904942)
        rpc.nfsd-4720  [001] ..s.    50.856596: __rpc_sleep_on_priority: RPC:     9 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.856596: __rpc_sleep_on_priority: RPC:     9 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.856596: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.856596: __rpc_execute: RPC:     9 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.856604: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.856604: xprt_complete_rqst: RPC:     9 xid 4245b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.856604: rpc_wake_up_task_queue_locked: RPC:     9 __rpc_wake_up_task (now 4294904942)
         rpcbind-1871  [003] ..s.    50.856605: rpc_wake_up_task_queue_locked: RPC:     9 disabling timer
         rpcbind-1871  [003] ..s.    50.856605: rpc_wake_up_task_queue_locked: RPC:     9 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.856606: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.856609: __rpc_execute: RPC:     9 sync task resuming
        rpc.nfsd-4720  [001] ....    50.856610: call_status: RPC:     9 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.856611: call_decode: RPC:     9 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.856611: call_decode: RPC:     9 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.856612: __rpc_execute: RPC:     9 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.856612: __rpc_execute: RPC:     9 release task
        rpc.nfsd-4720  [001] ....    50.856612: rpc_free: RPC:       freeing buffer of size 188 at ffff8804045aa000
        rpc.nfsd-4720  [001] ....    50.856613: xprt_release: RPC:     9 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.856613: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.856614: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.856614: rpc_free_task: RPC:     9 freeing task
        rpc.nfsd-4720  [001] ....    50.856616: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.856616: rpc_new_task: RPC:       allocated task ffff88040a645e00
        rpc.nfsd-4720  [001] ....    50.856617: __rpc_execute: RPC:    10 __rpc_execute flags=0x680
        rpc.nfsd-4720  [001] ....    50.856617: call_start: RPC:    10 call_start rpcbind4 proc SET (sync)
        rpc.nfsd-4720  [001] ....    50.856617: call_reserve: RPC:    10 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.856618: xprt_alloc_slot: RPC:    10 reserved req ffff880403542200 xid 4345b0ec
        rpc.nfsd-4720  [001] ....    50.856618: call_reserveresult: RPC:    10 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.856618: call_refresh: RPC:    10 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.856619: call_refreshresult: RPC:    10 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.856619: call_allocate: RPC:    10 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.856619: rpc_malloc: RPC:    10 allocated buffer of size 188 at ffff8804045aa000
        rpc.nfsd-4720  [001] ....    50.856620: call_bind: RPC:    10 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.856620: call_connect: RPC:    10 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.856620: call_transmit: RPC:    10 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.856620: xprt_prepare_transmit: RPC:    10 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.856621: call_transmit: RPC:    10 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.856622: xprt_transmit: RPC:    10 xprt_transmit(84)
        rpc.nfsd-4720  [001] ....    50.856631: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-4720  [001] ....    50.856631: xprt_transmit: RPC:    10 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.856633: __rpc_sleep_on_priority: RPC:    10 sleep_on(queue "xprt_pending" time 4294904942)
        rpc.nfsd-4720  [001] ..s.    50.856633: __rpc_sleep_on_priority: RPC:    10 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.856634: __rpc_sleep_on_priority: RPC:    10 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.856636: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.856637: __rpc_execute: RPC:    10 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.856661: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.856664: xprt_complete_rqst: RPC:    10 xid 4345b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.856665: rpc_wake_up_task_queue_locked: RPC:    10 __rpc_wake_up_task (now 4294904942)
         rpcbind-1871  [003] ..s.    50.856665: rpc_wake_up_task_queue_locked: RPC:    10 disabling timer
         rpcbind-1871  [003] ..s.    50.856666: rpc_wake_up_task_queue_locked: RPC:    10 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.856670: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.856690: __rpc_execute: RPC:    10 sync task resuming
        rpc.nfsd-4720  [001] ....    50.856692: call_status: RPC:    10 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.856692: call_decode: RPC:    10 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.856694: call_decode: RPC:    10 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.856695: __rpc_execute: RPC:    10 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.856695: __rpc_execute: RPC:    10 release task
        rpc.nfsd-4720  [001] ....    50.856697: rpc_free: RPC:       freeing buffer of size 188 at ffff8804045aa000
        rpc.nfsd-4720  [001] ....    50.856697: xprt_release: RPC:    10 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.856698: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.856699: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.856700: rpc_free_task: RPC:    10 freeing task
        rpc.nfsd-4720  [001] ....    50.856704: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.856705: rpc_new_task: RPC:       allocated task ffff88040a645e00
        rpc.nfsd-4720  [001] ....    50.856706: __rpc_execute: RPC:    11 __rpc_execute flags=0x680
        rpc.nfsd-4720  [001] ....    50.856707: call_start: RPC:    11 call_start rpcbind4 proc SET (sync)
        rpc.nfsd-4720  [001] ....    50.856708: call_reserve: RPC:    11 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.856709: xprt_alloc_slot: RPC:    11 reserved req ffff880403542200 xid 4445b0ec
        rpc.nfsd-4720  [001] ....    50.856709: call_reserveresult: RPC:    11 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.856710: call_refresh: RPC:    11 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.856711: call_refreshresult: RPC:    11 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.856712: call_allocate: RPC:    11 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.856713: rpc_malloc: RPC:    11 allocated buffer of size 188 at ffff8804045aa000
        rpc.nfsd-4720  [001] ....    50.856714: call_bind: RPC:    11 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.856715: call_connect: RPC:    11 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.856715: call_transmit: RPC:    11 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.856716: xprt_prepare_transmit: RPC:    11 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.856717: call_transmit: RPC:    11 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.856718: xprt_transmit: RPC:    11 xprt_transmit(84)
        rpc.nfsd-4720  [001] ....    50.856726: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-4720  [001] ....    50.856726: xprt_transmit: RPC:    11 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.856727: __rpc_sleep_on_priority: RPC:    11 sleep_on(queue "xprt_pending" time 4294904942)
        rpc.nfsd-4720  [001] ..s.    50.856728: __rpc_sleep_on_priority: RPC:    11 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.856729: __rpc_sleep_on_priority: RPC:    11 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.856731: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.856731: __rpc_execute: RPC:    11 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.856771: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.856773: xprt_complete_rqst: RPC:    11 xid 4445b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.856774: rpc_wake_up_task_queue_locked: RPC:    11 __rpc_wake_up_task (now 4294904942)
         rpcbind-1871  [003] ..s.    50.856775: rpc_wake_up_task_queue_locked: RPC:    11 disabling timer
         rpcbind-1871  [003] ..s.    50.856776: rpc_wake_up_task_queue_locked: RPC:    11 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.856779: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.856782: __rpc_execute: RPC:    11 sync task resuming
        rpc.nfsd-4720  [001] ....    50.856783: call_status: RPC:    11 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.856784: call_decode: RPC:    11 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.856786: call_decode: RPC:    11 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.856787: __rpc_execute: RPC:    11 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.856787: __rpc_execute: RPC:    11 release task
        rpc.nfsd-4720  [001] ....    50.856788: rpc_free: RPC:       freeing buffer of size 188 at ffff8804045aa000
        rpc.nfsd-4720  [001] ....    50.856789: xprt_release: RPC:    11 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.856790: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.856791: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.856792: rpc_free_task: RPC:    11 freeing task
        rpc.nfsd-4720  [001] ....    50.856795: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.856795: rpc_new_task: RPC:       allocated task ffff88040a645e00
        rpc.nfsd-4720  [001] ....    50.856796: __rpc_execute: RPC:    12 __rpc_execute flags=0x680
        rpc.nfsd-4720  [001] ....    50.856797: call_start: RPC:    12 call_start rpcbind4 proc SET (sync)
        rpc.nfsd-4720  [001] ....    50.856798: call_reserve: RPC:    12 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.856799: xprt_alloc_slot: RPC:    12 reserved req ffff880403542200 xid 4545b0ec
        rpc.nfsd-4720  [001] ....    50.856800: call_reserveresult: RPC:    12 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.856801: call_refresh: RPC:    12 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.856801: call_refreshresult: RPC:    12 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.856802: call_allocate: RPC:    12 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.856803: rpc_malloc: RPC:    12 allocated buffer of size 188 at ffff8804045aa000
        rpc.nfsd-4720  [001] ....    50.856804: call_bind: RPC:    12 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.856805: call_connect: RPC:    12 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.856805: call_transmit: RPC:    12 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.856806: xprt_prepare_transmit: RPC:    12 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.856807: call_transmit: RPC:    12 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.856808: xprt_transmit: RPC:    12 xprt_transmit(84)
        rpc.nfsd-4720  [001] ....    50.856814: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-4720  [001] ....    50.856815: xprt_transmit: RPC:    12 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.856816: __rpc_sleep_on_priority: RPC:    12 sleep_on(queue "xprt_pending" time 4294904942)
        rpc.nfsd-4720  [001] ..s.    50.856817: __rpc_sleep_on_priority: RPC:    12 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.856818: __rpc_sleep_on_priority: RPC:    12 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.856819: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.856820: __rpc_execute: RPC:    12 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.856838: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.856840: xprt_complete_rqst: RPC:    12 xid 4545b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.856841: rpc_wake_up_task_queue_locked: RPC:    12 __rpc_wake_up_task (now 4294904942)
         rpcbind-1871  [003] ..s.    50.856842: rpc_wake_up_task_queue_locked: RPC:    12 disabling timer
         rpcbind-1871  [003] ..s.    50.856843: rpc_wake_up_task_queue_locked: RPC:    12 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.856846: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.856848: __rpc_execute: RPC:    12 sync task resuming
        rpc.nfsd-4720  [001] ....    50.856849: call_status: RPC:    12 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.856850: call_decode: RPC:    12 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.856851: call_decode: RPC:    12 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.856852: __rpc_execute: RPC:    12 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.856853: __rpc_execute: RPC:    12 release task
        rpc.nfsd-4720  [001] ....    50.856854: rpc_free: RPC:       freeing buffer of size 188 at ffff8804045aa000
        rpc.nfsd-4720  [001] ....    50.856854: xprt_release: RPC:    12 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.856855: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.856856: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.856857: rpc_free_task: RPC:    12 freeing task
        rpc.nfsd-4720  [001] ....    50.856859: svc_setup_socket: setting up TCP socket for listening
        rpc.nfsd-4720  [001] ....    50.856860: svc_setup_socket: svc: svc_setup_socket created ffff880402bd4000 (inet ffff88040a708780)
        rpc.nfsd-4720  [001] ....    50.856882: svc_setup_socket: svc: svc_setup_socket ffff88040c7cacc0
        rpc.nfsd-4720  [001] ....    50.856884: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.856884: rpc_new_task: RPC:       allocated task ffff88040b326c00
        rpc.nfsd-4720  [001] ....    50.856884: __rpc_execute: RPC:    13 __rpc_execute flags=0x680
        rpc.nfsd-4720  [001] ....    50.856885: call_start: RPC:    13 call_start rpcbind4 proc SET (sync)
        rpc.nfsd-4720  [001] ....    50.856885: call_reserve: RPC:    13 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.856886: xprt_alloc_slot: RPC:    13 reserved req ffff880403542200 xid 4645b0ec
        rpc.nfsd-4720  [001] ....    50.856886: call_reserveresult: RPC:    13 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.856886: call_refresh: RPC:    13 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.856886: call_refreshresult: RPC:    13 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.856887: call_allocate: RPC:    13 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.856887: rpc_malloc: RPC:    13 allocated buffer of size 188 at ffff8804045aa000
        rpc.nfsd-4720  [001] ....    50.856887: call_bind: RPC:    13 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.856888: call_connect: RPC:    13 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.856888: call_transmit: RPC:    13 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.856888: xprt_prepare_transmit: RPC:    13 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.856889: call_transmit: RPC:    13 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.856889: xprt_transmit: RPC:    13 xprt_transmit(84)
        rpc.nfsd-4720  [001] ....    50.856892: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-4720  [001] ....    50.856892: xprt_transmit: RPC:    13 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.856893: __rpc_sleep_on_priority: RPC:    13 sleep_on(queue "xprt_pending" time 4294904942)
        rpc.nfsd-4720  [001] ..s.    50.856893: __rpc_sleep_on_priority: RPC:    13 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.856893: __rpc_sleep_on_priority: RPC:    13 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.856894: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.856894: __rpc_execute: RPC:    13 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.856901: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.856901: xprt_complete_rqst: RPC:    13 xid 4645b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.856902: rpc_wake_up_task_queue_locked: RPC:    13 __rpc_wake_up_task (now 4294904942)
         rpcbind-1871  [003] ..s.    50.856902: rpc_wake_up_task_queue_locked: RPC:    13 disabling timer
         rpcbind-1871  [003] ..s.    50.856902: rpc_wake_up_task_queue_locked: RPC:    13 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.856903: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.856905: __rpc_execute: RPC:    13 sync task resuming
        rpc.nfsd-4720  [001] ....    50.856905: call_status: RPC:    13 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.856905: call_decode: RPC:    13 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.856906: call_decode: RPC:    13 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.856906: __rpc_execute: RPC:    13 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.856907: __rpc_execute: RPC:    13 release task
        rpc.nfsd-4720  [001] ....    50.856907: rpc_free: RPC:       freeing buffer of size 188 at ffff8804045aa000
        rpc.nfsd-4720  [001] ....    50.856907: xprt_release: RPC:    13 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.856908: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.856908: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.856908: rpc_free_task: RPC:    13 freeing task
        rpc.nfsd-4720  [001] ....    50.856909: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.856909: rpc_new_task: RPC:       allocated task ffff88040b326c00
        rpc.nfsd-4720  [001] ....    50.856910: __rpc_execute: RPC:    14 __rpc_execute flags=0x680
        rpc.nfsd-4720  [001] ....    50.856910: call_start: RPC:    14 call_start rpcbind4 proc SET (sync)
        rpc.nfsd-4720  [001] ....    50.856910: call_reserve: RPC:    14 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.856911: xprt_alloc_slot: RPC:    14 reserved req ffff880403542200 xid 4745b0ec
        rpc.nfsd-4720  [001] ....    50.856911: call_reserveresult: RPC:    14 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.856911: call_refresh: RPC:    14 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.856912: call_refreshresult: RPC:    14 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.856912: call_allocate: RPC:    14 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.856912: rpc_malloc: RPC:    14 allocated buffer of size 188 at ffff8804045aa000
        rpc.nfsd-4720  [001] ....    50.856912: call_bind: RPC:    14 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.856913: call_connect: RPC:    14 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.856913: call_transmit: RPC:    14 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.856913: xprt_prepare_transmit: RPC:    14 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.856913: call_transmit: RPC:    14 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.856914: xprt_transmit: RPC:    14 xprt_transmit(84)
        rpc.nfsd-4720  [001] ....    50.856916: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-4720  [001] ....    50.856916: xprt_transmit: RPC:    14 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.856917: __rpc_sleep_on_priority: RPC:    14 sleep_on(queue "xprt_pending" time 4294904942)
        rpc.nfsd-4720  [001] ..s.    50.856917: __rpc_sleep_on_priority: RPC:    14 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.856917: __rpc_sleep_on_priority: RPC:    14 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.856918: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.856918: __rpc_execute: RPC:    14 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.856924: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.856925: xprt_complete_rqst: RPC:    14 xid 4745b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.856926: rpc_wake_up_task_queue_locked: RPC:    14 __rpc_wake_up_task (now 4294904942)
         rpcbind-1871  [003] ..s.    50.856926: rpc_wake_up_task_queue_locked: RPC:    14 disabling timer
         rpcbind-1871  [003] ..s.    50.856926: rpc_wake_up_task_queue_locked: RPC:    14 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.856927: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.856928: __rpc_execute: RPC:    14 sync task resuming
        rpc.nfsd-4720  [001] ....    50.856929: call_status: RPC:    14 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.856929: call_decode: RPC:    14 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.856929: call_decode: RPC:    14 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.856930: __rpc_execute: RPC:    14 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.856930: __rpc_execute: RPC:    14 release task
        rpc.nfsd-4720  [001] ....    50.856930: rpc_free: RPC:       freeing buffer of size 188 at ffff8804045aa000
        rpc.nfsd-4720  [001] ....    50.856930: xprt_release: RPC:    14 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.856931: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.856931: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.856931: rpc_free_task: RPC:    14 freeing task
        rpc.nfsd-4720  [001] ....    50.856932: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.856933: rpc_new_task: RPC:       allocated task ffff88040b326c00
        rpc.nfsd-4720  [001] ....    50.856933: __rpc_execute: RPC:    15 __rpc_execute flags=0x680
        rpc.nfsd-4720  [001] ....    50.856933: call_start: RPC:    15 call_start rpcbind4 proc SET (sync)
        rpc.nfsd-4720  [001] ....    50.856934: call_reserve: RPC:    15 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.856934: xprt_alloc_slot: RPC:    15 reserved req ffff880403542200 xid 4845b0ec
        rpc.nfsd-4720  [001] ....    50.856934: call_reserveresult: RPC:    15 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.856934: call_refresh: RPC:    15 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.856935: call_refreshresult: RPC:    15 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.856935: call_allocate: RPC:    15 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.856935: rpc_malloc: RPC:    15 allocated buffer of size 188 at ffff8804045aa000
        rpc.nfsd-4720  [001] ....    50.856935: call_bind: RPC:    15 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.856936: call_connect: RPC:    15 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.856936: call_transmit: RPC:    15 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.856936: xprt_prepare_transmit: RPC:    15 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.856936: call_transmit: RPC:    15 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.856937: xprt_transmit: RPC:    15 xprt_transmit(84)
        rpc.nfsd-4720  [001] ....    50.856939: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-4720  [001] ....    50.856939: xprt_transmit: RPC:    15 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.856939: __rpc_sleep_on_priority: RPC:    15 sleep_on(queue "xprt_pending" time 4294904942)
        rpc.nfsd-4720  [001] ..s.    50.856940: __rpc_sleep_on_priority: RPC:    15 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.856940: __rpc_sleep_on_priority: RPC:    15 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.856941: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.856941: __rpc_execute: RPC:    15 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.856947: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.856948: xprt_complete_rqst: RPC:    15 xid 4845b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.856949: rpc_wake_up_task_queue_locked: RPC:    15 __rpc_wake_up_task (now 4294904942)
         rpcbind-1871  [003] ..s.    50.856949: rpc_wake_up_task_queue_locked: RPC:    15 disabling timer
         rpcbind-1871  [003] ..s.    50.856949: rpc_wake_up_task_queue_locked: RPC:    15 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.856950: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.856951: __rpc_execute: RPC:    15 sync task resuming
        rpc.nfsd-4720  [001] ....    50.856952: call_status: RPC:    15 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.856952: call_decode: RPC:    15 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.856952: call_decode: RPC:    15 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.856953: __rpc_execute: RPC:    15 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.856953: __rpc_execute: RPC:    15 release task
        rpc.nfsd-4720  [001] ....    50.856953: rpc_free: RPC:       freeing buffer of size 188 at ffff8804045aa000
        rpc.nfsd-4720  [001] ....    50.856953: xprt_release: RPC:    15 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.856954: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.856954: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.856954: rpc_free_task: RPC:    15 freeing task
        rpc.nfsd-4720  [001] ....    50.856955: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.856955: rpc_new_task: RPC:       allocated task ffff88040b326c00
        rpc.nfsd-4720  [001] ....    50.856956: __rpc_execute: RPC:    16 __rpc_execute flags=0x680
        rpc.nfsd-4720  [001] ....    50.856956: call_start: RPC:    16 call_start rpcbind4 proc SET (sync)
        rpc.nfsd-4720  [001] ....    50.856956: call_reserve: RPC:    16 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.856957: xprt_alloc_slot: RPC:    16 reserved req ffff880403542200 xid 4945b0ec
        rpc.nfsd-4720  [001] ....    50.856957: call_reserveresult: RPC:    16 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.856957: call_refresh: RPC:    16 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.856958: call_refreshresult: RPC:    16 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.856958: call_allocate: RPC:    16 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.856958: rpc_malloc: RPC:    16 allocated buffer of size 188 at ffff8804045aa000
        rpc.nfsd-4720  [001] ....    50.856959: call_bind: RPC:    16 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.856959: call_connect: RPC:    16 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.856959: call_transmit: RPC:    16 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.856959: xprt_prepare_transmit: RPC:    16 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.856960: call_transmit: RPC:    16 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.856960: xprt_transmit: RPC:    16 xprt_transmit(84)
        rpc.nfsd-4720  [001] ....    50.856962: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-4720  [001] ....    50.856962: xprt_transmit: RPC:    16 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.856963: __rpc_sleep_on_priority: RPC:    16 sleep_on(queue "xprt_pending" time 4294904942)
        rpc.nfsd-4720  [001] ..s.    50.856963: __rpc_sleep_on_priority: RPC:    16 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.856963: __rpc_sleep_on_priority: RPC:    16 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.856964: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.856964: __rpc_execute: RPC:    16 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.856971: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.856971: xprt_complete_rqst: RPC:    16 xid 4945b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.856972: rpc_wake_up_task_queue_locked: RPC:    16 __rpc_wake_up_task (now 4294904942)
         rpcbind-1871  [003] ..s.    50.856972: rpc_wake_up_task_queue_locked: RPC:    16 disabling timer
         rpcbind-1871  [003] ..s.    50.856972: rpc_wake_up_task_queue_locked: RPC:    16 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.856973: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.856974: __rpc_execute: RPC:    16 sync task resuming
        rpc.nfsd-4720  [001] ....    50.856975: call_status: RPC:    16 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.856975: call_decode: RPC:    16 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.856976: call_decode: RPC:    16 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.856976: __rpc_execute: RPC:    16 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.856976: __rpc_execute: RPC:    16 release task
        rpc.nfsd-4720  [001] ....    50.856976: rpc_free: RPC:       freeing buffer of size 188 at ffff8804045aa000
        rpc.nfsd-4720  [001] ....    50.856977: xprt_release: RPC:    16 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.856977: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.856977: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.856978: rpc_free_task: RPC:    16 freeing task
        rpc.nfsd-4720  [001] ....    50.856979: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.856979: rpc_new_task: RPC:       allocated task ffff88040b326c00
        rpc.nfsd-4720  [001] ....    50.856979: __rpc_execute: RPC:    17 __rpc_execute flags=0x680
        rpc.nfsd-4720  [001] ....    50.856979: call_start: RPC:    17 call_start rpcbind4 proc SET (sync)
        rpc.nfsd-4720  [001] ....    50.856980: call_reserve: RPC:    17 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.856980: xprt_alloc_slot: RPC:    17 reserved req ffff880403542200 xid 4a45b0ec
        rpc.nfsd-4720  [001] ....    50.856980: call_reserveresult: RPC:    17 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.856980: call_refresh: RPC:    17 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.856981: call_refreshresult: RPC:    17 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.856981: call_allocate: RPC:    17 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.856981: rpc_malloc: RPC:    17 allocated buffer of size 188 at ffff8804045aa000
        rpc.nfsd-4720  [001] ....    50.856982: call_bind: RPC:    17 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.856982: call_connect: RPC:    17 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.856982: call_transmit: RPC:    17 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.856982: xprt_prepare_transmit: RPC:    17 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.856983: call_transmit: RPC:    17 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.856983: xprt_transmit: RPC:    17 xprt_transmit(84)
        rpc.nfsd-4720  [001] ....    50.856985: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-4720  [001] ....    50.856985: xprt_transmit: RPC:    17 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.856986: __rpc_sleep_on_priority: RPC:    17 sleep_on(queue "xprt_pending" time 4294904942)
        rpc.nfsd-4720  [001] ..s.    50.856986: __rpc_sleep_on_priority: RPC:    17 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.856986: __rpc_sleep_on_priority: RPC:    17 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.856987: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.856987: __rpc_execute: RPC:    17 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.856994: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.856994: xprt_complete_rqst: RPC:    17 xid 4a45b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.856995: rpc_wake_up_task_queue_locked: RPC:    17 __rpc_wake_up_task (now 4294904942)
         rpcbind-1871  [003] ..s.    50.856995: rpc_wake_up_task_queue_locked: RPC:    17 disabling timer
         rpcbind-1871  [003] ..s.    50.856996: rpc_wake_up_task_queue_locked: RPC:    17 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.856997: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.856998: __rpc_execute: RPC:    17 sync task resuming
        rpc.nfsd-4720  [001] ....    50.856998: call_status: RPC:    17 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.856998: call_decode: RPC:    17 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.856999: call_decode: RPC:    17 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.856999: __rpc_execute: RPC:    17 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.856999: __rpc_execute: RPC:    17 release task
        rpc.nfsd-4720  [001] ....    50.857000: rpc_free: RPC:       freeing buffer of size 188 at ffff8804045aa000
        rpc.nfsd-4720  [001] ....    50.857000: xprt_release: RPC:    17 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.857000: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.857001: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.857001: rpc_free_task: RPC:    17 freeing task
        rpc.nfsd-4720  [001] ....    50.857002: svc_write_space: svc: socket ffff880402ba1000(inet ffff880407b2cc00), write_space busy=1
        rpc.nfsd-4720  [001] ....    50.857003: svc_setup_socket: svc: kernel_setsockopt returned 0
        rpc.nfsd-4720  [001] ....    50.857003: svc_setup_socket: svc: svc_setup_socket created ffff880402ba1000 (inet ffff880407b2cc00)
        rpc.nfsd-4720  [001] ....    50.857568: svc_setup_socket: svc: svc_setup_socket ffff88040ec230c0
        rpc.nfsd-4720  [001] ....    50.857571: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.857571: rpc_new_task: RPC:       allocated task ffff88040a14b900
        rpc.nfsd-4720  [001] ....    50.857572: __rpc_execute: RPC:    18 __rpc_execute flags=0x680
        rpc.nfsd-4720  [001] ....    50.857572: call_start: RPC:    18 call_start rpcbind4 proc SET (sync)
        rpc.nfsd-4720  [001] ....    50.857573: call_reserve: RPC:    18 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.857573: xprt_alloc_slot: RPC:    18 reserved req ffff880403542200 xid 4b45b0ec
        rpc.nfsd-4720  [001] ....    50.857573: call_reserveresult: RPC:    18 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.857574: call_refresh: RPC:    18 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.857574: call_refreshresult: RPC:    18 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.857574: call_allocate: RPC:    18 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.857575: rpc_malloc: RPC:    18 allocated buffer of size 188 at ffff8800d8dc0000
        rpc.nfsd-4720  [001] ....    50.857575: call_bind: RPC:    18 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.857575: call_connect: RPC:    18 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.857576: call_transmit: RPC:    18 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.857576: xprt_prepare_transmit: RPC:    18 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.857576: call_transmit: RPC:    18 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.857577: xprt_transmit: RPC:    18 xprt_transmit(80)
        rpc.nfsd-4720  [001] ....    50.857581: xs_local_send_request: RPC:       xs_local_send_request(80) = 0
        rpc.nfsd-4720  [001] ....    50.857581: xprt_transmit: RPC:    18 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.857581: __rpc_sleep_on_priority: RPC:    18 sleep_on(queue "xprt_pending" time 4294904943)
        rpc.nfsd-4720  [001] ..s.    50.857582: __rpc_sleep_on_priority: RPC:    18 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.857582: __rpc_sleep_on_priority: RPC:    18 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.857583: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.857583: __rpc_execute: RPC:    18 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.857592: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.857593: xprt_complete_rqst: RPC:    18 xid 4b45b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.857593: rpc_wake_up_task_queue_locked: RPC:    18 __rpc_wake_up_task (now 4294904943)
         rpcbind-1871  [003] ..s.    50.857594: rpc_wake_up_task_queue_locked: RPC:    18 disabling timer
         rpcbind-1871  [003] ..s.    50.857594: rpc_wake_up_task_queue_locked: RPC:    18 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.857595: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.857596: __rpc_execute: RPC:    18 sync task resuming
        rpc.nfsd-4720  [001] ....    50.857597: call_status: RPC:    18 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.857597: call_decode: RPC:    18 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.857598: call_decode: RPC:    18 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.857598: __rpc_execute: RPC:    18 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.857598: __rpc_execute: RPC:    18 release task
        rpc.nfsd-4720  [001] ....    50.857599: rpc_free: RPC:       freeing buffer of size 188 at ffff8800d8dc0000
        rpc.nfsd-4720  [001] ....    50.857599: xprt_release: RPC:    18 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.857600: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.857600: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.857601: rpc_free_task: RPC:    18 freeing task
        rpc.nfsd-4720  [001] ....    50.857602: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.857602: rpc_new_task: RPC:       allocated task ffff88040a14b900
        rpc.nfsd-4720  [001] ....    50.857602: __rpc_execute: RPC:    19 __rpc_execute flags=0x680
        rpc.nfsd-4720  [001] ....    50.857602: call_start: RPC:    19 call_start rpcbind4 proc SET (sync)
        rpc.nfsd-4720  [001] ....    50.857603: call_reserve: RPC:    19 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.857603: xprt_alloc_slot: RPC:    19 reserved req ffff880403542200 xid 4c45b0ec
        rpc.nfsd-4720  [001] ....    50.857603: call_reserveresult: RPC:    19 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.857604: call_refresh: RPC:    19 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.857604: call_refreshresult: RPC:    19 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.857604: call_allocate: RPC:    19 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.857605: rpc_malloc: RPC:    19 allocated buffer of size 188 at ffff8800d8dc0000
        rpc.nfsd-4720  [001] ....    50.857605: call_bind: RPC:    19 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.857605: call_connect: RPC:    19 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.857605: call_transmit: RPC:    19 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.857606: xprt_prepare_transmit: RPC:    19 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.857606: call_transmit: RPC:    19 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.857606: xprt_transmit: RPC:    19 xprt_transmit(80)
        rpc.nfsd-4720  [001] ....    50.857608: xs_local_send_request: RPC:       xs_local_send_request(80) = 0
        rpc.nfsd-4720  [001] ....    50.857609: xprt_transmit: RPC:    19 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.857609: __rpc_sleep_on_priority: RPC:    19 sleep_on(queue "xprt_pending" time 4294904943)
        rpc.nfsd-4720  [001] ..s.    50.857609: __rpc_sleep_on_priority: RPC:    19 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.857610: __rpc_sleep_on_priority: RPC:    19 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.857610: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.857610: __rpc_execute: RPC:    19 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.857617: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.857618: xprt_complete_rqst: RPC:    19 xid 4c45b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.857618: rpc_wake_up_task_queue_locked: RPC:    19 __rpc_wake_up_task (now 4294904943)
         rpcbind-1871  [003] ..s.    50.857618: rpc_wake_up_task_queue_locked: RPC:    19 disabling timer
         rpcbind-1871  [003] ..s.    50.857618: rpc_wake_up_task_queue_locked: RPC:    19 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.857619: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.857620: __rpc_execute: RPC:    19 sync task resuming
        rpc.nfsd-4720  [001] ....    50.857621: call_status: RPC:    19 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.857621: call_decode: RPC:    19 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.857622: call_decode: RPC:    19 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.857622: __rpc_execute: RPC:    19 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.857622: __rpc_execute: RPC:    19 release task
        rpc.nfsd-4720  [001] ....    50.857623: rpc_free: RPC:       freeing buffer of size 188 at ffff8800d8dc0000
        rpc.nfsd-4720  [001] ....    50.857623: xprt_release: RPC:    19 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.857623: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.857623: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.857624: rpc_free_task: RPC:    19 freeing task
        rpc.nfsd-4720  [001] ....    50.857625: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.857625: rpc_new_task: RPC:       allocated task ffff88040a14b900
        rpc.nfsd-4720  [001] ....    50.857625: __rpc_execute: RPC:    20 __rpc_execute flags=0x680
        rpc.nfsd-4720  [001] ....    50.857625: call_start: RPC:    20 call_start rpcbind4 proc SET (sync)
        rpc.nfsd-4720  [001] ....    50.857626: call_reserve: RPC:    20 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.857626: xprt_alloc_slot: RPC:    20 reserved req ffff880403542200 xid 4d45b0ec
        rpc.nfsd-4720  [001] ....    50.857626: call_reserveresult: RPC:    20 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.857627: call_refresh: RPC:    20 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.857627: call_refreshresult: RPC:    20 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.857627: call_allocate: RPC:    20 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.857628: rpc_malloc: RPC:    20 allocated buffer of size 188 at ffff8800d8dc0000
        rpc.nfsd-4720  [001] ....    50.857628: call_bind: RPC:    20 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.857628: call_connect: RPC:    20 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.857628: call_transmit: RPC:    20 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.857628: xprt_prepare_transmit: RPC:    20 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.857629: call_transmit: RPC:    20 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.857629: xprt_transmit: RPC:    20 xprt_transmit(80)
        rpc.nfsd-4720  [001] ....    50.857631: xs_local_send_request: RPC:       xs_local_send_request(80) = 0
        rpc.nfsd-4720  [001] ....    50.857632: xprt_transmit: RPC:    20 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.857632: __rpc_sleep_on_priority: RPC:    20 sleep_on(queue "xprt_pending" time 4294904943)
        rpc.nfsd-4720  [001] ..s.    50.857632: __rpc_sleep_on_priority: RPC:    20 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.857632: __rpc_sleep_on_priority: RPC:    20 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.857633: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.857633: __rpc_execute: RPC:    20 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.857640: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.857640: xprt_complete_rqst: RPC:    20 xid 4d45b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.857641: rpc_wake_up_task_queue_locked: RPC:    20 __rpc_wake_up_task (now 4294904943)
         rpcbind-1871  [003] ..s.    50.857641: rpc_wake_up_task_queue_locked: RPC:    20 disabling timer
         rpcbind-1871  [003] ..s.    50.857641: rpc_wake_up_task_queue_locked: RPC:    20 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.857642: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.857643: __rpc_execute: RPC:    20 sync task resuming
        rpc.nfsd-4720  [001] ....    50.857644: call_status: RPC:    20 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.857644: call_decode: RPC:    20 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.857645: call_decode: RPC:    20 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.857645: __rpc_execute: RPC:    20 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.857645: __rpc_execute: RPC:    20 release task
        rpc.nfsd-4720  [001] ....    50.857645: rpc_free: RPC:       freeing buffer of size 188 at ffff8800d8dc0000
        rpc.nfsd-4720  [001] ....    50.857646: xprt_release: RPC:    20 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.857646: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.857646: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.857646: rpc_free_task: RPC:    20 freeing task
        rpc.nfsd-4720  [001] ....    50.857647: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.857648: rpc_new_task: RPC:       allocated task ffff88040a14b900
        rpc.nfsd-4720  [001] ....    50.857648: __rpc_execute: RPC:    21 __rpc_execute flags=0x680
        rpc.nfsd-4720  [001] ....    50.857648: call_start: RPC:    21 call_start rpcbind4 proc SET (sync)
        rpc.nfsd-4720  [001] ....    50.857649: call_reserve: RPC:    21 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.857649: xprt_alloc_slot: RPC:    21 reserved req ffff880403542200 xid 4e45b0ec
        rpc.nfsd-4720  [001] ....    50.857649: call_reserveresult: RPC:    21 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.857649: call_refresh: RPC:    21 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.857650: call_refreshresult: RPC:    21 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.857650: call_allocate: RPC:    21 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.857650: rpc_malloc: RPC:    21 allocated buffer of size 188 at ffff8800d8dc0000
        rpc.nfsd-4720  [001] ....    50.857651: call_bind: RPC:    21 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.857651: call_connect: RPC:    21 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.857651: call_transmit: RPC:    21 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.857651: xprt_prepare_transmit: RPC:    21 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.857652: call_transmit: RPC:    21 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.857652: xprt_transmit: RPC:    21 xprt_transmit(80)
        rpc.nfsd-4720  [001] ....    50.857654: xs_local_send_request: RPC:       xs_local_send_request(80) = 0
        rpc.nfsd-4720  [001] ....    50.857654: xprt_transmit: RPC:    21 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.857655: __rpc_sleep_on_priority: RPC:    21 sleep_on(queue "xprt_pending" time 4294904943)
        rpc.nfsd-4720  [001] ..s.    50.857655: __rpc_sleep_on_priority: RPC:    21 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.857655: __rpc_sleep_on_priority: RPC:    21 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.857656: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.857656: __rpc_execute: RPC:    21 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.857662: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.857663: xprt_complete_rqst: RPC:    21 xid 4e45b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.857664: rpc_wake_up_task_queue_locked: RPC:    21 __rpc_wake_up_task (now 4294904943)
         rpcbind-1871  [003] ..s.    50.857664: rpc_wake_up_task_queue_locked: RPC:    21 disabling timer
         rpcbind-1871  [003] ..s.    50.857664: rpc_wake_up_task_queue_locked: RPC:    21 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.857665: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.857666: __rpc_execute: RPC:    21 sync task resuming
        rpc.nfsd-4720  [001] ....    50.857667: call_status: RPC:    21 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.857667: call_decode: RPC:    21 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.857667: call_decode: RPC:    21 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.857668: __rpc_execute: RPC:    21 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.857668: __rpc_execute: RPC:    21 release task
        rpc.nfsd-4720  [001] ....    50.857668: rpc_free: RPC:       freeing buffer of size 188 at ffff8800d8dc0000
        rpc.nfsd-4720  [001] ....    50.857669: xprt_release: RPC:    21 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.857669: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.857669: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.857669: rpc_free_task: RPC:    21 freeing task
        rpc.nfsd-4720  [001] ....    50.857670: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.857671: rpc_new_task: RPC:       allocated task ffff88040a14b900
        rpc.nfsd-4720  [001] ....    50.857671: __rpc_execute: RPC:    22 __rpc_execute flags=0x680
        rpc.nfsd-4720  [001] ....    50.857671: call_start: RPC:    22 call_start rpcbind4 proc SET (sync)
        rpc.nfsd-4720  [001] ....    50.857672: call_reserve: RPC:    22 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.857672: xprt_alloc_slot: RPC:    22 reserved req ffff880403542200 xid 4f45b0ec
        rpc.nfsd-4720  [001] ....    50.857672: call_reserveresult: RPC:    22 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.857672: call_refresh: RPC:    22 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.857673: call_refreshresult: RPC:    22 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.857673: call_allocate: RPC:    22 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.857673: rpc_malloc: RPC:    22 allocated buffer of size 188 at ffff8800d8dc0000
        rpc.nfsd-4720  [001] ....    50.857674: call_bind: RPC:    22 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.857674: call_connect: RPC:    22 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.857674: call_transmit: RPC:    22 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.857674: xprt_prepare_transmit: RPC:    22 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.857675: call_transmit: RPC:    22 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.857675: xprt_transmit: RPC:    22 xprt_transmit(80)
        rpc.nfsd-4720  [001] ....    50.857677: xs_local_send_request: RPC:       xs_local_send_request(80) = 0
        rpc.nfsd-4720  [001] ....    50.857677: xprt_transmit: RPC:    22 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.857678: __rpc_sleep_on_priority: RPC:    22 sleep_on(queue "xprt_pending" time 4294904943)
        rpc.nfsd-4720  [001] ..s.    50.857678: __rpc_sleep_on_priority: RPC:    22 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.857678: __rpc_sleep_on_priority: RPC:    22 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.857679: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.857679: __rpc_execute: RPC:    22 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.857685: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.857686: xprt_complete_rqst: RPC:    22 xid 4f45b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.857687: rpc_wake_up_task_queue_locked: RPC:    22 __rpc_wake_up_task (now 4294904943)
         rpcbind-1871  [003] ..s.    50.857687: rpc_wake_up_task_queue_locked: RPC:    22 disabling timer
         rpcbind-1871  [003] ..s.    50.857687: rpc_wake_up_task_queue_locked: RPC:    22 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.857688: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.857689: __rpc_execute: RPC:    22 sync task resuming
        rpc.nfsd-4720  [001] ....    50.857690: call_status: RPC:    22 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.857690: call_decode: RPC:    22 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.857690: call_decode: RPC:    22 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.857691: __rpc_execute: RPC:    22 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.857691: __rpc_execute: RPC:    22 release task
        rpc.nfsd-4720  [001] ....    50.857691: rpc_free: RPC:       freeing buffer of size 188 at ffff8800d8dc0000
        rpc.nfsd-4720  [001] ....    50.857691: xprt_release: RPC:    22 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.857692: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.857692: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.857692: rpc_free_task: RPC:    22 freeing task
        rpc.nfsd-4720  [001] ....    50.857693: svc_setup_socket: setting up TCP socket for listening
        rpc.nfsd-4720  [001] ....    50.857693: svc_setup_socket: svc: svc_setup_socket created ffff88040cf94000 (inet ffff88040a152800)
        rpc.nfsd-4720  [001] ....    50.857706: svc_setup_socket: svc: svc_setup_socket ffff880402295340
        rpc.nfsd-4720  [001] ....    50.857708: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.857708: rpc_new_task: RPC:       allocated task ffff88040b0c0e00
        rpc.nfsd-4720  [001] ....    50.857708: __rpc_execute: RPC:    23 __rpc_execute flags=0x680
        rpc.nfsd-4720  [001] ....    50.857709: call_start: RPC:    23 call_start rpcbind4 proc SET (sync)
        rpc.nfsd-4720  [001] ....    50.857709: call_reserve: RPC:    23 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.857709: xprt_alloc_slot: RPC:    23 reserved req ffff880403542200 xid 5045b0ec
        rpc.nfsd-4720  [001] ....    50.857710: call_reserveresult: RPC:    23 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.857710: call_refresh: RPC:    23 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.857710: call_refreshresult: RPC:    23 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.857711: call_allocate: RPC:    23 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.857711: rpc_malloc: RPC:    23 allocated buffer of size 188 at ffff8800d8dc0000
        rpc.nfsd-4720  [001] ....    50.857711: call_bind: RPC:    23 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.857712: call_connect: RPC:    23 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.857712: call_transmit: RPC:    23 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.857712: xprt_prepare_transmit: RPC:    23 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.857712: call_transmit: RPC:    23 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.857713: xprt_transmit: RPC:    23 xprt_transmit(80)
        rpc.nfsd-4720  [001] ....    50.857716: xs_local_send_request: RPC:       xs_local_send_request(80) = 0
        rpc.nfsd-4720  [001] ....    50.857716: xprt_transmit: RPC:    23 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.857716: __rpc_sleep_on_priority: RPC:    23 sleep_on(queue "xprt_pending" time 4294904943)
        rpc.nfsd-4720  [001] ..s.    50.857717: __rpc_sleep_on_priority: RPC:    23 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.857717: __rpc_sleep_on_priority: RPC:    23 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.857718: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.857718: __rpc_execute: RPC:    23 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.857724: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.857725: xprt_complete_rqst: RPC:    23 xid 5045b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.857725: rpc_wake_up_task_queue_locked: RPC:    23 __rpc_wake_up_task (now 4294904943)
         rpcbind-1871  [003] ..s.    50.857725: rpc_wake_up_task_queue_locked: RPC:    23 disabling timer
         rpcbind-1871  [003] ..s.    50.857726: rpc_wake_up_task_queue_locked: RPC:    23 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.857727: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.857728: __rpc_execute: RPC:    23 sync task resuming
        rpc.nfsd-4720  [001] ....    50.857729: call_status: RPC:    23 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.857729: call_decode: RPC:    23 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.857729: call_decode: RPC:    23 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.857730: __rpc_execute: RPC:    23 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.857730: __rpc_execute: RPC:    23 release task
        rpc.nfsd-4720  [001] ....    50.857730: rpc_free: RPC:       freeing buffer of size 188 at ffff8800d8dc0000
        rpc.nfsd-4720  [001] ....    50.857731: xprt_release: RPC:    23 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.857731: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.857731: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.857732: rpc_free_task: RPC:    23 freeing task
        rpc.nfsd-4720  [001] ....    50.857732: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.857733: rpc_new_task: RPC:       allocated task ffff88040b0c0e00
        rpc.nfsd-4720  [001] ....    50.857733: __rpc_execute: RPC:    24 __rpc_execute flags=0x680
        rpc.nfsd-4720  [001] ....    50.857734: call_start: RPC:    24 call_start rpcbind4 proc SET (sync)
        rpc.nfsd-4720  [001] ....    50.857734: call_reserve: RPC:    24 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.857734: xprt_alloc_slot: RPC:    24 reserved req ffff880403542200 xid 5145b0ec
        rpc.nfsd-4720  [001] ....    50.857734: call_reserveresult: RPC:    24 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.857735: call_refresh: RPC:    24 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.857735: call_refreshresult: RPC:    24 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.857735: call_allocate: RPC:    24 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.857736: rpc_malloc: RPC:    24 allocated buffer of size 188 at ffff8800d8dc0000
        rpc.nfsd-4720  [001] ....    50.857736: call_bind: RPC:    24 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.857736: call_connect: RPC:    24 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.857736: call_transmit: RPC:    24 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.857737: xprt_prepare_transmit: RPC:    24 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.857737: call_transmit: RPC:    24 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.857737: xprt_transmit: RPC:    24 xprt_transmit(80)
        rpc.nfsd-4720  [001] ....    50.857740: xs_local_send_request: RPC:       xs_local_send_request(80) = 0
        rpc.nfsd-4720  [001] ....    50.857740: xprt_transmit: RPC:    24 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.857740: __rpc_sleep_on_priority: RPC:    24 sleep_on(queue "xprt_pending" time 4294904943)
        rpc.nfsd-4720  [001] ..s.    50.857741: __rpc_sleep_on_priority: RPC:    24 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.857741: __rpc_sleep_on_priority: RPC:    24 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.857741: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.857742: __rpc_execute: RPC:    24 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.857748: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.857749: xprt_complete_rqst: RPC:    24 xid 5145b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.857749: rpc_wake_up_task_queue_locked: RPC:    24 __rpc_wake_up_task (now 4294904943)
         rpcbind-1871  [003] ..s.    50.857749: rpc_wake_up_task_queue_locked: RPC:    24 disabling timer
         rpcbind-1871  [003] ..s.    50.857750: rpc_wake_up_task_queue_locked: RPC:    24 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.857751: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.857752: __rpc_execute: RPC:    24 sync task resuming
        rpc.nfsd-4720  [001] ....    50.857752: call_status: RPC:    24 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.857753: call_decode: RPC:    24 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.857753: call_decode: RPC:    24 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.857753: __rpc_execute: RPC:    24 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.857753: __rpc_execute: RPC:    24 release task
        rpc.nfsd-4720  [001] ....    50.857754: rpc_free: RPC:       freeing buffer of size 188 at ffff8800d8dc0000
        rpc.nfsd-4720  [001] ....    50.857754: xprt_release: RPC:    24 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.857754: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.857755: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.857755: rpc_free_task: RPC:    24 freeing task
        rpc.nfsd-4720  [001] ....    50.857756: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.857756: rpc_new_task: RPC:       allocated task ffff88040b0c0e00
        rpc.nfsd-4720  [001] ....    50.857756: __rpc_execute: RPC:    25 __rpc_execute flags=0x680
        rpc.nfsd-4720  [001] ....    50.857757: call_start: RPC:    25 call_start rpcbind4 proc SET (sync)
        rpc.nfsd-4720  [001] ....    50.857757: call_reserve: RPC:    25 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.857757: xprt_alloc_slot: RPC:    25 reserved req ffff880403542200 xid 5245b0ec
        rpc.nfsd-4720  [001] ....    50.857758: call_reserveresult: RPC:    25 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.857758: call_refresh: RPC:    25 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.857758: call_refreshresult: RPC:    25 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.857759: call_allocate: RPC:    25 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.857759: rpc_malloc: RPC:    25 allocated buffer of size 188 at ffff8800d8dc0000
        rpc.nfsd-4720  [001] ....    50.857759: call_bind: RPC:    25 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.857759: call_connect: RPC:    25 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.857760: call_transmit: RPC:    25 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.857760: xprt_prepare_transmit: RPC:    25 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.857760: call_transmit: RPC:    25 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.857761: xprt_transmit: RPC:    25 xprt_transmit(80)
        rpc.nfsd-4720  [001] ....    50.857763: xs_local_send_request: RPC:       xs_local_send_request(80) = 0
        rpc.nfsd-4720  [001] ....    50.857763: xprt_transmit: RPC:    25 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.857763: __rpc_sleep_on_priority: RPC:    25 sleep_on(queue "xprt_pending" time 4294904943)
        rpc.nfsd-4720  [001] ..s.    50.857764: __rpc_sleep_on_priority: RPC:    25 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.857764: __rpc_sleep_on_priority: RPC:    25 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.857764: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.857765: __rpc_execute: RPC:    25 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.857771: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.857772: xprt_complete_rqst: RPC:    25 xid 5245b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.857772: rpc_wake_up_task_queue_locked: RPC:    25 __rpc_wake_up_task (now 4294904943)
         rpcbind-1871  [003] ..s.    50.857772: rpc_wake_up_task_queue_locked: RPC:    25 disabling timer
         rpcbind-1871  [003] ..s.    50.857773: rpc_wake_up_task_queue_locked: RPC:    25 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.857774: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.857775: __rpc_execute: RPC:    25 sync task resuming
        rpc.nfsd-4720  [001] ....    50.857775: call_status: RPC:    25 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.857776: call_decode: RPC:    25 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.857776: call_decode: RPC:    25 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.857776: __rpc_execute: RPC:    25 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.857777: __rpc_execute: RPC:    25 release task
        rpc.nfsd-4720  [001] ....    50.857777: rpc_free: RPC:       freeing buffer of size 188 at ffff8800d8dc0000
        rpc.nfsd-4720  [001] ....    50.857777: xprt_release: RPC:    25 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.857778: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.857778: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.857778: rpc_free_task: RPC:    25 freeing task
        rpc.nfsd-4720  [001] ....    50.857779: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.857779: rpc_new_task: RPC:       allocated task ffff88040b0c0e00
        rpc.nfsd-4720  [001] ....    50.857780: __rpc_execute: RPC:    26 __rpc_execute flags=0x680
        rpc.nfsd-4720  [001] ....    50.857780: call_start: RPC:    26 call_start rpcbind4 proc SET (sync)
        rpc.nfsd-4720  [001] ....    50.857780: call_reserve: RPC:    26 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.857781: xprt_alloc_slot: RPC:    26 reserved req ffff880403542200 xid 5345b0ec
        rpc.nfsd-4720  [001] ....    50.857781: call_reserveresult: RPC:    26 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.857781: call_refresh: RPC:    26 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.857781: call_refreshresult: RPC:    26 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.857782: call_allocate: RPC:    26 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.857782: rpc_malloc: RPC:    26 allocated buffer of size 188 at ffff8800d8dc0000
        rpc.nfsd-4720  [001] ....    50.857782: call_bind: RPC:    26 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.857782: call_connect: RPC:    26 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.857783: call_transmit: RPC:    26 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.857783: xprt_prepare_transmit: RPC:    26 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.857783: call_transmit: RPC:    26 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.857784: xprt_transmit: RPC:    26 xprt_transmit(80)
        rpc.nfsd-4720  [001] ....    50.857786: xs_local_send_request: RPC:       xs_local_send_request(80) = 0
        rpc.nfsd-4720  [001] ....    50.857786: xprt_transmit: RPC:    26 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.857786: __rpc_sleep_on_priority: RPC:    26 sleep_on(queue "xprt_pending" time 4294904943)
        rpc.nfsd-4720  [001] ..s.    50.857787: __rpc_sleep_on_priority: RPC:    26 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.857787: __rpc_sleep_on_priority: RPC:    26 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.857787: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.857788: __rpc_execute: RPC:    26 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.857794: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.857795: xprt_complete_rqst: RPC:    26 xid 5345b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.857795: rpc_wake_up_task_queue_locked: RPC:    26 __rpc_wake_up_task (now 4294904943)
         rpcbind-1871  [003] ..s.    50.857795: rpc_wake_up_task_queue_locked: RPC:    26 disabling timer
         rpcbind-1871  [003] ..s.    50.857796: rpc_wake_up_task_queue_locked: RPC:    26 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.857797: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.857798: __rpc_execute: RPC:    26 sync task resuming
        rpc.nfsd-4720  [001] ....    50.857798: call_status: RPC:    26 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.857798: call_decode: RPC:    26 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.857799: call_decode: RPC:    26 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.857799: __rpc_execute: RPC:    26 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.857799: __rpc_execute: RPC:    26 release task
        rpc.nfsd-4720  [001] ....    50.857800: rpc_free: RPC:       freeing buffer of size 188 at ffff8800d8dc0000
        rpc.nfsd-4720  [001] ....    50.857800: xprt_release: RPC:    26 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.857800: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.857801: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.857801: rpc_free_task: RPC:    26 freeing task
        rpc.nfsd-4720  [001] ....    50.857802: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.857802: rpc_new_task: RPC:       allocated task ffff88040b0c0e00
        rpc.nfsd-4720  [001] ....    50.857802: __rpc_execute: RPC:    27 __rpc_execute flags=0x680
        rpc.nfsd-4720  [001] ....    50.857803: call_start: RPC:    27 call_start rpcbind4 proc SET (sync)
        rpc.nfsd-4720  [001] ....    50.857803: call_reserve: RPC:    27 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.857803: xprt_alloc_slot: RPC:    27 reserved req ffff880403542200 xid 5445b0ec
        rpc.nfsd-4720  [001] ....    50.857804: call_reserveresult: RPC:    27 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.857804: call_refresh: RPC:    27 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.857804: call_refreshresult: RPC:    27 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.857804: call_allocate: RPC:    27 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.857805: rpc_malloc: RPC:    27 allocated buffer of size 188 at ffff8800d8dc0000
        rpc.nfsd-4720  [001] ....    50.857805: call_bind: RPC:    27 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.857805: call_connect: RPC:    27 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.857806: call_transmit: RPC:    27 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.857806: xprt_prepare_transmit: RPC:    27 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.857806: call_transmit: RPC:    27 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.857806: xprt_transmit: RPC:    27 xprt_transmit(80)
        rpc.nfsd-4720  [001] ....    50.857809: xs_local_send_request: RPC:       xs_local_send_request(80) = 0
        rpc.nfsd-4720  [001] ....    50.857809: xprt_transmit: RPC:    27 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.857809: __rpc_sleep_on_priority: RPC:    27 sleep_on(queue "xprt_pending" time 4294904943)
        rpc.nfsd-4720  [001] ..s.    50.857809: __rpc_sleep_on_priority: RPC:    27 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.857810: __rpc_sleep_on_priority: RPC:    27 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.857810: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.857810: __rpc_execute: RPC:    27 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.857817: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.857818: xprt_complete_rqst: RPC:    27 xid 5445b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.857818: rpc_wake_up_task_queue_locked: RPC:    27 __rpc_wake_up_task (now 4294904943)
         rpcbind-1871  [003] ..s.    50.857818: rpc_wake_up_task_queue_locked: RPC:    27 disabling timer
         rpcbind-1871  [003] ..s.    50.857819: rpc_wake_up_task_queue_locked: RPC:    27 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.857820: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.857821: __rpc_execute: RPC:    27 sync task resuming
        rpc.nfsd-4720  [001] ....    50.857821: call_status: RPC:    27 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.857821: call_decode: RPC:    27 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.857822: call_decode: RPC:    27 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.857822: __rpc_execute: RPC:    27 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.857822: __rpc_execute: RPC:    27 release task
        rpc.nfsd-4720  [001] ....    50.857823: rpc_free: RPC:       freeing buffer of size 188 at ffff8800d8dc0000
        rpc.nfsd-4720  [001] ....    50.857823: xprt_release: RPC:    27 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.857823: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.857824: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.857824: rpc_free_task: RPC:    27 freeing task
        rpc.nfsd-4720  [001] ....    50.857824: svc_write_space: svc: socket ffff880402966000(inet ffff8800db854180), write_space busy=1
        rpc.nfsd-4720  [001] ....    50.857825: svc_setup_socket: svc: kernel_setsockopt returned 0
        rpc.nfsd-4720  [001] ....    50.857825: svc_setup_socket: svc: svc_setup_socket created ffff880402966000 (inet ffff8800db854180)
        rpc.nfsd-4720  [001] ....    50.857974: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.857974: rpc_new_task: RPC:       allocated task ffff88040b718200
        rpc.nfsd-4720  [001] ....    50.857975: __rpc_execute: RPC:    28 __rpc_execute flags=0x2280
        rpc.nfsd-4720  [001] ....    50.857975: call_start: RPC:    28 call_start rpcbind4 proc UNSET (sync)
        rpc.nfsd-4720  [001] ....    50.857976: call_reserve: RPC:    28 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.857976: xprt_alloc_slot: RPC:    28 reserved req ffff880403542200 xid 5545b0ec
        rpc.nfsd-4720  [001] ....    50.857977: call_reserveresult: RPC:    28 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.857977: call_refresh: RPC:    28 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.857977: call_refreshresult: RPC:    28 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.857978: call_allocate: RPC:    28 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.857978: rpc_malloc: RPC:    28 allocated buffer of size 188 at ffff8800d8dc0000
        rpc.nfsd-4720  [001] ....    50.857979: call_bind: RPC:    28 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.857979: call_connect: RPC:    28 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.857979: call_transmit: RPC:    28 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.857979: xprt_prepare_transmit: RPC:    28 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.857980: call_transmit: RPC:    28 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.857981: xprt_transmit: RPC:    28 xprt_transmit(68)
        rpc.nfsd-4720  [001] ....    50.857984: xs_local_send_request: RPC:       xs_local_send_request(68) = 0
        rpc.nfsd-4720  [001] ....    50.857984: xprt_transmit: RPC:    28 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.857985: __rpc_sleep_on_priority: RPC:    28 sleep_on(queue "xprt_pending" time 4294904943)
        rpc.nfsd-4720  [001] ..s.    50.857985: __rpc_sleep_on_priority: RPC:    28 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.857985: __rpc_sleep_on_priority: RPC:    28 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.857986: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.857986: __rpc_execute: RPC:    28 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.857994: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.857994: xprt_complete_rqst: RPC:    28 xid 5545b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.857995: rpc_wake_up_task_queue_locked: RPC:    28 __rpc_wake_up_task (now 4294904943)
         rpcbind-1871  [003] ..s.    50.857995: rpc_wake_up_task_queue_locked: RPC:    28 disabling timer
         rpcbind-1871  [003] ..s.    50.857995: rpc_wake_up_task_queue_locked: RPC:    28 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.857996: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.857998: __rpc_execute: RPC:    28 sync task resuming
        rpc.nfsd-4720  [001] ....    50.857998: call_status: RPC:    28 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.857999: call_decode: RPC:    28 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.857999: call_decode: RPC:    28 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.858000: __rpc_execute: RPC:    28 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.858000: __rpc_execute: RPC:    28 release task
        rpc.nfsd-4720  [001] ....    50.858000: rpc_free: RPC:       freeing buffer of size 188 at ffff8800d8dc0000
        rpc.nfsd-4720  [001] ....    50.858001: xprt_release: RPC:    28 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.858001: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.858002: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.858002: rpc_free_task: RPC:    28 freeing task
        rpc.nfsd-4720  [001] ....    50.858003: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.858003: rpc_new_task: RPC:       allocated task ffff88040b718200
        rpc.nfsd-4720  [001] ....    50.858003: __rpc_execute: RPC:    29 __rpc_execute flags=0x2280
        rpc.nfsd-4720  [001] ....    50.858004: call_start: RPC:    29 call_start rpcbind4 proc UNSET (sync)
        rpc.nfsd-4720  [001] ....    50.858004: call_reserve: RPC:    29 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.858004: xprt_alloc_slot: RPC:    29 reserved req ffff880403542200 xid 5645b0ec
        rpc.nfsd-4720  [001] ....    50.858005: call_reserveresult: RPC:    29 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.858005: call_refresh: RPC:    29 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.858005: call_refreshresult: RPC:    29 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.858006: call_allocate: RPC:    29 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.858006: rpc_malloc: RPC:    29 allocated buffer of size 188 at ffff8800d8dc0000
        rpc.nfsd-4720  [001] ....    50.858006: call_bind: RPC:    29 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.858007: call_connect: RPC:    29 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.858007: call_transmit: RPC:    29 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.858007: xprt_prepare_transmit: RPC:    29 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.858008: call_transmit: RPC:    29 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.858008: xprt_transmit: RPC:    29 xprt_transmit(68)
        rpc.nfsd-4720  [001] ....    50.858010: xs_local_send_request: RPC:       xs_local_send_request(68) = 0
        rpc.nfsd-4720  [001] ....    50.858011: xprt_transmit: RPC:    29 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.858011: __rpc_sleep_on_priority: RPC:    29 sleep_on(queue "xprt_pending" time 4294904943)
        rpc.nfsd-4720  [001] ..s.    50.858011: __rpc_sleep_on_priority: RPC:    29 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.858012: __rpc_sleep_on_priority: RPC:    29 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.858012: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.858012: __rpc_execute: RPC:    29 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.858019: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.858020: xprt_complete_rqst: RPC:    29 xid 5645b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.858020: rpc_wake_up_task_queue_locked: RPC:    29 __rpc_wake_up_task (now 4294904943)
         rpcbind-1871  [003] ..s.    50.858020: rpc_wake_up_task_queue_locked: RPC:    29 disabling timer
         rpcbind-1871  [003] ..s.    50.858021: rpc_wake_up_task_queue_locked: RPC:    29 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.858022: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.858023: __rpc_execute: RPC:    29 sync task resuming
        rpc.nfsd-4720  [001] ....    50.858023: call_status: RPC:    29 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.858024: call_decode: RPC:    29 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.858024: call_decode: RPC:    29 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.858025: __rpc_execute: RPC:    29 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.858025: __rpc_execute: RPC:    29 release task
        rpc.nfsd-4720  [001] ....    50.858025: rpc_free: RPC:       freeing buffer of size 188 at ffff8800d8dc0000
        rpc.nfsd-4720  [001] ....    50.858026: xprt_release: RPC:    29 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.858026: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.858026: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.858027: rpc_free_task: RPC:    29 freeing task
        rpc.nfsd-4720  [001] ....    50.858027: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.858027: rpc_new_task: RPC:       allocated task ffff88040b718200
        rpc.nfsd-4720  [001] ....    50.858028: __rpc_execute: RPC:    30 __rpc_execute flags=0x2280
        rpc.nfsd-4720  [001] ....    50.858028: call_start: RPC:    30 call_start rpcbind4 proc UNSET (sync)
        rpc.nfsd-4720  [001] ....    50.858029: call_reserve: RPC:    30 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.858029: xprt_alloc_slot: RPC:    30 reserved req ffff880403542200 xid 5745b0ec
        rpc.nfsd-4720  [001] ....    50.858029: call_reserveresult: RPC:    30 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.858030: call_refresh: RPC:    30 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.858030: call_refreshresult: RPC:    30 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.858030: call_allocate: RPC:    30 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.858030: rpc_malloc: RPC:    30 allocated buffer of size 188 at ffff8800d8dc0000
        rpc.nfsd-4720  [001] ....    50.858031: call_bind: RPC:    30 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.858031: call_connect: RPC:    30 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.858031: call_transmit: RPC:    30 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.858032: xprt_prepare_transmit: RPC:    30 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.858032: call_transmit: RPC:    30 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.858032: xprt_transmit: RPC:    30 xprt_transmit(68)
        rpc.nfsd-4720  [001] ....    50.858035: xs_local_send_request: RPC:       xs_local_send_request(68) = 0
        rpc.nfsd-4720  [001] ....    50.858035: xprt_transmit: RPC:    30 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.858035: __rpc_sleep_on_priority: RPC:    30 sleep_on(queue "xprt_pending" time 4294904943)
        rpc.nfsd-4720  [001] ..s.    50.858036: __rpc_sleep_on_priority: RPC:    30 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.858036: __rpc_sleep_on_priority: RPC:    30 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.858036: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.858037: __rpc_execute: RPC:    30 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.858043: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.858044: xprt_complete_rqst: RPC:    30 xid 5745b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.858044: rpc_wake_up_task_queue_locked: RPC:    30 __rpc_wake_up_task (now 4294904943)
         rpcbind-1871  [003] ..s.    50.858045: rpc_wake_up_task_queue_locked: RPC:    30 disabling timer
         rpcbind-1871  [003] ..s.    50.858045: rpc_wake_up_task_queue_locked: RPC:    30 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.858046: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.858047: __rpc_execute: RPC:    30 sync task resuming
        rpc.nfsd-4720  [001] ....    50.858048: call_status: RPC:    30 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.858048: call_decode: RPC:    30 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.858049: call_decode: RPC:    30 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.858049: __rpc_execute: RPC:    30 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.858049: __rpc_execute: RPC:    30 release task
        rpc.nfsd-4720  [001] ....    50.858050: rpc_free: RPC:       freeing buffer of size 188 at ffff8800d8dc0000
        rpc.nfsd-4720  [001] ....    50.858050: xprt_release: RPC:    30 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.858050: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.858051: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.858051: rpc_free_task: RPC:    30 freeing task
        rpc.nfsd-4720  [001] ....    50.858053: svc_create_socket: svc: svc_create_socket(lockd, 17, 0.0.0.0, port=0)
        rpc.nfsd-4720  [001] ....    50.858058: svc_setup_socket: svc: svc_setup_socket ffff8804022955c0
        rpc.nfsd-4720  [001] ....    50.858059: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.858060: rpc_new_task: RPC:       allocated task ffff88040b718200
        rpc.nfsd-4720  [001] ....    50.858060: __rpc_execute: RPC:    31 __rpc_execute flags=0x680
        rpc.nfsd-4720  [001] ....    50.858060: call_start: RPC:    31 call_start rpcbind4 proc SET (sync)
        rpc.nfsd-4720  [001] ....    50.858061: call_reserve: RPC:    31 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.858061: xprt_alloc_slot: RPC:    31 reserved req ffff880403542200 xid 5845b0ec
        rpc.nfsd-4720  [001] ....    50.858061: call_reserveresult: RPC:    31 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.858062: call_refresh: RPC:    31 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.858062: call_refreshresult: RPC:    31 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.858062: call_allocate: RPC:    31 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.858063: rpc_malloc: RPC:    31 allocated buffer of size 188 at ffff8800d8dc0000
        rpc.nfsd-4720  [001] ....    50.858063: call_bind: RPC:    31 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.858063: call_connect: RPC:    31 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.858064: call_transmit: RPC:    31 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.858064: xprt_prepare_transmit: RPC:    31 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.858064: call_transmit: RPC:    31 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.858065: xprt_transmit: RPC:    31 xprt_transmit(88)
        rpc.nfsd-4720  [001] ....    50.858067: xs_local_send_request: RPC:       xs_local_send_request(88) = 0
        rpc.nfsd-4720  [001] ....    50.858068: xprt_transmit: RPC:    31 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.858068: __rpc_sleep_on_priority: RPC:    31 sleep_on(queue "xprt_pending" time 4294904943)
        rpc.nfsd-4720  [001] ..s.    50.858068: __rpc_sleep_on_priority: RPC:    31 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.858069: __rpc_sleep_on_priority: RPC:    31 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.858069: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.858070: __rpc_execute: RPC:    31 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.858080: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.858081: xprt_complete_rqst: RPC:    31 xid 5845b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.858081: rpc_wake_up_task_queue_locked: RPC:    31 __rpc_wake_up_task (now 4294904943)
         rpcbind-1871  [003] ..s.    50.858081: rpc_wake_up_task_queue_locked: RPC:    31 disabling timer
         rpcbind-1871  [003] ..s.    50.858081: rpc_wake_up_task_queue_locked: RPC:    31 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.858082: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.858084: __rpc_execute: RPC:    31 sync task resuming
        rpc.nfsd-4720  [001] ....    50.858084: call_status: RPC:    31 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.858085: call_decode: RPC:    31 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.858085: call_decode: RPC:    31 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.858085: __rpc_execute: RPC:    31 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.858086: __rpc_execute: RPC:    31 release task
        rpc.nfsd-4720  [001] ....    50.858086: rpc_free: RPC:       freeing buffer of size 188 at ffff8800d8dc0000
        rpc.nfsd-4720  [001] ....    50.858086: xprt_release: RPC:    31 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.858087: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.858087: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.858087: rpc_free_task: RPC:    31 freeing task
        rpc.nfsd-4720  [001] ....    50.858088: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.858089: rpc_new_task: RPC:       allocated task ffff88040b718200
        rpc.nfsd-4720  [001] ....    50.858089: __rpc_execute: RPC:    32 __rpc_execute flags=0x680
        rpc.nfsd-4720  [001] ....    50.858089: call_start: RPC:    32 call_start rpcbind4 proc SET (sync)
        rpc.nfsd-4720  [001] ....    50.858090: call_reserve: RPC:    32 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.858090: xprt_alloc_slot: RPC:    32 reserved req ffff880403542200 xid 5945b0ec
        rpc.nfsd-4720  [001] ....    50.858090: call_reserveresult: RPC:    32 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.858090: call_refresh: RPC:    32 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.858091: call_refreshresult: RPC:    32 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.858091: call_allocate: RPC:    32 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.858091: rpc_malloc: RPC:    32 allocated buffer of size 188 at ffff8800d8dc0000
        rpc.nfsd-4720  [001] ....    50.858091: call_bind: RPC:    32 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.858092: call_connect: RPC:    32 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.858092: call_transmit: RPC:    32 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.858092: xprt_prepare_transmit: RPC:    32 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.858092: call_transmit: RPC:    32 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.858093: xprt_transmit: RPC:    32 xprt_transmit(88)
        rpc.nfsd-4720  [001] ....    50.858095: xs_local_send_request: RPC:       xs_local_send_request(88) = 0
        rpc.nfsd-4720  [001] ....    50.858095: xprt_transmit: RPC:    32 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.858096: __rpc_sleep_on_priority: RPC:    32 sleep_on(queue "xprt_pending" time 4294904943)
        rpc.nfsd-4720  [001] ..s.    50.858096: __rpc_sleep_on_priority: RPC:    32 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.858096: __rpc_sleep_on_priority: RPC:    32 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.858097: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.858097: __rpc_execute: RPC:    32 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.858104: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.858104: xprt_complete_rqst: RPC:    32 xid 5945b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.858105: rpc_wake_up_task_queue_locked: RPC:    32 __rpc_wake_up_task (now 4294904943)
         rpcbind-1871  [003] ..s.    50.858105: rpc_wake_up_task_queue_locked: RPC:    32 disabling timer
         rpcbind-1871  [003] ..s.    50.858105: rpc_wake_up_task_queue_locked: RPC:    32 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.858106: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.858107: __rpc_execute: RPC:    32 sync task resuming
        rpc.nfsd-4720  [001] ....    50.858108: call_status: RPC:    32 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.858108: call_decode: RPC:    32 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.858109: call_decode: RPC:    32 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.858109: __rpc_execute: RPC:    32 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.858109: __rpc_execute: RPC:    32 release task
        rpc.nfsd-4720  [001] ....    50.858109: rpc_free: RPC:       freeing buffer of size 188 at ffff8800d8dc0000
        rpc.nfsd-4720  [001] ....    50.858110: xprt_release: RPC:    32 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.858110: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.858110: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.858111: rpc_free_task: RPC:    32 freeing task
        rpc.nfsd-4720  [001] ....    50.858112: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.858112: rpc_new_task: RPC:       allocated task ffff88040b718200
        rpc.nfsd-4720  [001] ....    50.858112: __rpc_execute: RPC:    33 __rpc_execute flags=0x680
        rpc.nfsd-4720  [001] ....    50.858112: call_start: RPC:    33 call_start rpcbind4 proc SET (sync)
        rpc.nfsd-4720  [001] ....    50.858113: call_reserve: RPC:    33 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.858113: xprt_alloc_slot: RPC:    33 reserved req ffff880403542200 xid 5a45b0ec
        rpc.nfsd-4720  [001] ....    50.858113: call_reserveresult: RPC:    33 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.858114: call_refresh: RPC:    33 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.858114: call_refreshresult: RPC:    33 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.858114: call_allocate: RPC:    33 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.858114: rpc_malloc: RPC:    33 allocated buffer of size 188 at ffff8800d8dc0000
        rpc.nfsd-4720  [001] ....    50.858115: call_bind: RPC:    33 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.858115: call_connect: RPC:    33 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.858115: call_transmit: RPC:    33 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.858115: xprt_prepare_transmit: RPC:    33 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.858116: call_transmit: RPC:    33 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.858116: xprt_transmit: RPC:    33 xprt_transmit(88)
        rpc.nfsd-4720  [001] ....    50.858118: xs_local_send_request: RPC:       xs_local_send_request(88) = 0
        rpc.nfsd-4720  [001] ....    50.858118: xprt_transmit: RPC:    33 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.858119: __rpc_sleep_on_priority: RPC:    33 sleep_on(queue "xprt_pending" time 4294904943)
        rpc.nfsd-4720  [001] ..s.    50.858119: __rpc_sleep_on_priority: RPC:    33 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.858119: __rpc_sleep_on_priority: RPC:    33 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.858120: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.858120: __rpc_execute: RPC:    33 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.858127: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.858128: xprt_complete_rqst: RPC:    33 xid 5a45b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.858128: rpc_wake_up_task_queue_locked: RPC:    33 __rpc_wake_up_task (now 4294904943)
         rpcbind-1871  [003] ..s.    50.858128: rpc_wake_up_task_queue_locked: RPC:    33 disabling timer
         rpcbind-1871  [003] ..s.    50.858128: rpc_wake_up_task_queue_locked: RPC:    33 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.858129: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.858131: __rpc_execute: RPC:    33 sync task resuming
        rpc.nfsd-4720  [001] ....    50.858131: call_status: RPC:    33 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.858131: call_decode: RPC:    33 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.858132: call_decode: RPC:    33 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.858132: __rpc_execute: RPC:    33 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.858132: __rpc_execute: RPC:    33 release task
        rpc.nfsd-4720  [001] ....    50.858133: rpc_free: RPC:       freeing buffer of size 188 at ffff8800d8dc0000
        rpc.nfsd-4720  [001] ....    50.858133: xprt_release: RPC:    33 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.858133: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.858133: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.858134: rpc_free_task: RPC:    33 freeing task
        rpc.nfsd-4720  [001] ....    50.858134: svc_write_space: svc: socket ffff8800db83a000(inet ffff88040a14eb80), write_space busy=1
        rpc.nfsd-4720  [001] ....    50.858135: svc_setup_socket: svc: kernel_setsockopt returned 0
        rpc.nfsd-4720  [001] ....    50.858135: svc_setup_socket: svc: svc_setup_socket created ffff8800db83a000 (inet ffff88040a14eb80)
        rpc.nfsd-4720  [001] ....    50.858137: svc_create_socket: svc: svc_create_socket(lockd, 6, 0.0.0.0, port=0)
        rpc.nfsd-4720  [001] ....    50.858141: svc_setup_socket: svc: svc_setup_socket ffff88040acedd40
        rpc.nfsd-4720  [001] ....    50.858142: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.858143: rpc_new_task: RPC:       allocated task ffff88040b718200
        rpc.nfsd-4720  [001] ....    50.858143: __rpc_execute: RPC:    34 __rpc_execute flags=0x680
        rpc.nfsd-4720  [001] ....    50.858143: call_start: RPC:    34 call_start rpcbind4 proc SET (sync)
        rpc.nfsd-4720  [001] ....    50.858144: call_reserve: RPC:    34 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.858144: xprt_alloc_slot: RPC:    34 reserved req ffff880403542200 xid 5b45b0ec
        rpc.nfsd-4720  [001] ....    50.858144: call_reserveresult: RPC:    34 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.858145: call_refresh: RPC:    34 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.858145: call_refreshresult: RPC:    34 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.858145: call_allocate: RPC:    34 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.858146: rpc_malloc: RPC:    34 allocated buffer of size 188 at ffff88040a84a800
        rpc.nfsd-4720  [001] ....    50.858146: call_bind: RPC:    34 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.858146: call_connect: RPC:    34 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.858146: call_transmit: RPC:    34 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.858147: xprt_prepare_transmit: RPC:    34 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.858147: call_transmit: RPC:    34 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.858147: xprt_transmit: RPC:    34 xprt_transmit(88)
        rpc.nfsd-4720  [001] ....    50.858150: xs_local_send_request: RPC:       xs_local_send_request(88) = 0
        rpc.nfsd-4720  [001] ....    50.858150: xprt_transmit: RPC:    34 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.858150: __rpc_sleep_on_priority: RPC:    34 sleep_on(queue "xprt_pending" time 4294904943)
        rpc.nfsd-4720  [001] ..s.    50.858150: __rpc_sleep_on_priority: RPC:    34 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.858151: __rpc_sleep_on_priority: RPC:    34 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.858151: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.858152: __rpc_execute: RPC:    34 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.858158: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.858159: xprt_complete_rqst: RPC:    34 xid 5b45b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.858159: rpc_wake_up_task_queue_locked: RPC:    34 __rpc_wake_up_task (now 4294904943)
         rpcbind-1871  [003] ..s.    50.858160: rpc_wake_up_task_queue_locked: RPC:    34 disabling timer
         rpcbind-1871  [003] ..s.    50.858160: rpc_wake_up_task_queue_locked: RPC:    34 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.858161: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.858162: __rpc_execute: RPC:    34 sync task resuming
        rpc.nfsd-4720  [001] ....    50.858163: call_status: RPC:    34 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.858163: call_decode: RPC:    34 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.858164: call_decode: RPC:    34 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.858164: __rpc_execute: RPC:    34 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.858164: __rpc_execute: RPC:    34 release task
        rpc.nfsd-4720  [001] ....    50.858164: rpc_free: RPC:       freeing buffer of size 188 at ffff88040a84a800
        rpc.nfsd-4720  [001] ....    50.858165: xprt_release: RPC:    34 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.858165: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.858165: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.858166: rpc_free_task: RPC:    34 freeing task
        rpc.nfsd-4720  [001] ....    50.858167: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.858167: rpc_new_task: RPC:       allocated task ffff88040b718200
        rpc.nfsd-4720  [001] ....    50.858167: __rpc_execute: RPC:    35 __rpc_execute flags=0x680
        rpc.nfsd-4720  [001] ....    50.858168: call_start: RPC:    35 call_start rpcbind4 proc SET (sync)
        rpc.nfsd-4720  [001] ....    50.858168: call_reserve: RPC:    35 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.858168: xprt_alloc_slot: RPC:    35 reserved req ffff880403542200 xid 5c45b0ec
        rpc.nfsd-4720  [001] ....    50.858168: call_reserveresult: RPC:    35 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.858169: call_refresh: RPC:    35 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.858169: call_refreshresult: RPC:    35 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.858169: call_allocate: RPC:    35 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.858170: rpc_malloc: RPC:    35 allocated buffer of size 188 at ffff88040a84a800
        rpc.nfsd-4720  [001] ....    50.858170: call_bind: RPC:    35 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.858170: call_connect: RPC:    35 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.858170: call_transmit: RPC:    35 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.858171: xprt_prepare_transmit: RPC:    35 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.858171: call_transmit: RPC:    35 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.858171: xprt_transmit: RPC:    35 xprt_transmit(88)
        rpc.nfsd-4720  [001] ....    50.858173: xs_local_send_request: RPC:       xs_local_send_request(88) = 0
        rpc.nfsd-4720  [001] ....    50.858173: xprt_transmit: RPC:    35 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.858174: __rpc_sleep_on_priority: RPC:    35 sleep_on(queue "xprt_pending" time 4294904943)
        rpc.nfsd-4720  [001] ..s.    50.858174: __rpc_sleep_on_priority: RPC:    35 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.858174: __rpc_sleep_on_priority: RPC:    35 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.858175: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.858175: __rpc_execute: RPC:    35 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.858182: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.858183: xprt_complete_rqst: RPC:    35 xid 5c45b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.858183: rpc_wake_up_task_queue_locked: RPC:    35 __rpc_wake_up_task (now 4294904943)
         rpcbind-1871  [003] ..s.    50.858184: rpc_wake_up_task_queue_locked: RPC:    35 disabling timer
         rpcbind-1871  [003] ..s.    50.858184: rpc_wake_up_task_queue_locked: RPC:    35 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.858185: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.858186: __rpc_execute: RPC:    35 sync task resuming
        rpc.nfsd-4720  [001] ....    50.858186: call_status: RPC:    35 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.858187: call_decode: RPC:    35 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.858187: call_decode: RPC:    35 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.858187: __rpc_execute: RPC:    35 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.858188: __rpc_execute: RPC:    35 release task
        rpc.nfsd-4720  [001] ....    50.858188: rpc_free: RPC:       freeing buffer of size 188 at ffff88040a84a800
        rpc.nfsd-4720  [001] ....    50.858188: xprt_release: RPC:    35 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.858189: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.858189: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.858189: rpc_free_task: RPC:    35 freeing task
        rpc.nfsd-4720  [001] ....    50.858190: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.858190: rpc_new_task: RPC:       allocated task ffff88040b718200
        rpc.nfsd-4720  [001] ....    50.858191: __rpc_execute: RPC:    36 __rpc_execute flags=0x680
        rpc.nfsd-4720  [001] ....    50.858191: call_start: RPC:    36 call_start rpcbind4 proc SET (sync)
        rpc.nfsd-4720  [001] ....    50.858191: call_reserve: RPC:    36 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.858192: xprt_alloc_slot: RPC:    36 reserved req ffff880403542200 xid 5d45b0ec
        rpc.nfsd-4720  [001] ....    50.858192: call_reserveresult: RPC:    36 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.858192: call_refresh: RPC:    36 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.858192: call_refreshresult: RPC:    36 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.858193: call_allocate: RPC:    36 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.858193: rpc_malloc: RPC:    36 allocated buffer of size 188 at ffff88040a84a800
        rpc.nfsd-4720  [001] ....    50.858193: call_bind: RPC:    36 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.858194: call_connect: RPC:    36 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.858194: call_transmit: RPC:    36 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.858194: xprt_prepare_transmit: RPC:    36 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.858194: call_transmit: RPC:    36 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.858195: xprt_transmit: RPC:    36 xprt_transmit(88)
        rpc.nfsd-4720  [001] ....    50.858197: xs_local_send_request: RPC:       xs_local_send_request(88) = 0
        rpc.nfsd-4720  [001] ....    50.858197: xprt_transmit: RPC:    36 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.858198: __rpc_sleep_on_priority: RPC:    36 sleep_on(queue "xprt_pending" time 4294904943)
        rpc.nfsd-4720  [001] ..s.    50.858198: __rpc_sleep_on_priority: RPC:    36 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.858198: __rpc_sleep_on_priority: RPC:    36 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.858199: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.858199: __rpc_execute: RPC:    36 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.858206: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.858206: xprt_complete_rqst: RPC:    36 xid 5d45b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.858207: rpc_wake_up_task_queue_locked: RPC:    36 __rpc_wake_up_task (now 4294904943)
         rpcbind-1871  [003] ..s.    50.858207: rpc_wake_up_task_queue_locked: RPC:    36 disabling timer
         rpcbind-1871  [003] ..s.    50.858207: rpc_wake_up_task_queue_locked: RPC:    36 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.858208: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.858209: __rpc_execute: RPC:    36 sync task resuming
        rpc.nfsd-4720  [001] ....    50.858210: call_status: RPC:    36 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.858210: call_decode: RPC:    36 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.858210: call_decode: RPC:    36 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.858211: __rpc_execute: RPC:    36 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.858211: __rpc_execute: RPC:    36 release task
        rpc.nfsd-4720  [001] ....    50.858211: rpc_free: RPC:       freeing buffer of size 188 at ffff88040a84a800
        rpc.nfsd-4720  [001] ....    50.858212: xprt_release: RPC:    36 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.858212: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.858212: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.858212: rpc_free_task: RPC:    36 freeing task
        rpc.nfsd-4720  [001] ....    50.858213: svc_setup_socket: setting up TCP socket for listening
        rpc.nfsd-4720  [001] ....    50.858213: svc_setup_socket: svc: svc_setup_socket created ffff88040298e000 (inet ffff88040a708040)
        rpc.nfsd-4720  [001] ....    50.858215: svc_create_socket: svc: svc_create_socket(lockd, 17, 0000:0000:0000:0000:0000:0000:0000:0000, port=0)
        rpc.nfsd-4720  [001] ....    50.858217: svc_setup_socket: svc: svc_setup_socket ffff88040ba2c840
        rpc.nfsd-4720  [001] ....    50.858218: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.858218: rpc_new_task: RPC:       allocated task ffff88040b718200
        rpc.nfsd-4720  [001] ....    50.858219: __rpc_execute: RPC:    37 __rpc_execute flags=0x680
        rpc.nfsd-4720  [001] ....    50.858219: call_start: RPC:    37 call_start rpcbind4 proc SET (sync)
        rpc.nfsd-4720  [001] ....    50.858220: call_reserve: RPC:    37 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.858220: xprt_alloc_slot: RPC:    37 reserved req ffff880403542200 xid 5e45b0ec
        rpc.nfsd-4720  [001] ....    50.858220: call_reserveresult: RPC:    37 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.858220: call_refresh: RPC:    37 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.858221: call_refreshresult: RPC:    37 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.858221: call_allocate: RPC:    37 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.858221: rpc_malloc: RPC:    37 allocated buffer of size 188 at ffff88040a84a800
        rpc.nfsd-4720  [001] ....    50.858222: call_bind: RPC:    37 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.858222: call_connect: RPC:    37 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.858222: call_transmit: RPC:    37 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.858222: xprt_prepare_transmit: RPC:    37 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.858223: call_transmit: RPC:    37 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.858223: xprt_transmit: RPC:    37 xprt_transmit(84)
        rpc.nfsd-4720  [001] ....    50.858225: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-4720  [001] ....    50.858225: xprt_transmit: RPC:    37 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.858226: __rpc_sleep_on_priority: RPC:    37 sleep_on(queue "xprt_pending" time 4294904943)
        rpc.nfsd-4720  [001] ..s.    50.858226: __rpc_sleep_on_priority: RPC:    37 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.858226: __rpc_sleep_on_priority: RPC:    37 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.858227: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.858227: __rpc_execute: RPC:    37 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.858234: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.858234: xprt_complete_rqst: RPC:    37 xid 5e45b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.858235: rpc_wake_up_task_queue_locked: RPC:    37 __rpc_wake_up_task (now 4294904943)
         rpcbind-1871  [003] ..s.    50.858235: rpc_wake_up_task_queue_locked: RPC:    37 disabling timer
         rpcbind-1871  [003] ..s.    50.858235: rpc_wake_up_task_queue_locked: RPC:    37 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.858236: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.858237: __rpc_execute: RPC:    37 sync task resuming
        rpc.nfsd-4720  [001] ....    50.858238: call_status: RPC:    37 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.858238: call_decode: RPC:    37 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.858239: call_decode: RPC:    37 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.858239: __rpc_execute: RPC:    37 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.858239: __rpc_execute: RPC:    37 release task
        rpc.nfsd-4720  [001] ....    50.858239: rpc_free: RPC:       freeing buffer of size 188 at ffff88040a84a800
        rpc.nfsd-4720  [001] ....    50.858240: xprt_release: RPC:    37 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.858240: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.858240: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.858241: rpc_free_task: RPC:    37 freeing task
        rpc.nfsd-4720  [001] ....    50.858242: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.858242: rpc_new_task: RPC:       allocated task ffff88040b718200
        rpc.nfsd-4720  [001] ....    50.858242: __rpc_execute: RPC:    38 __rpc_execute flags=0x680
        rpc.nfsd-4720  [001] ....    50.858243: call_start: RPC:    38 call_start rpcbind4 proc SET (sync)
        rpc.nfsd-4720  [001] ....    50.858243: call_reserve: RPC:    38 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.858243: xprt_alloc_slot: RPC:    38 reserved req ffff880403542200 xid 5f45b0ec
        rpc.nfsd-4720  [001] ....    50.858243: call_reserveresult: RPC:    38 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.858244: call_refresh: RPC:    38 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.858244: call_refreshresult: RPC:    38 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.858244: call_allocate: RPC:    38 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.858245: rpc_malloc: RPC:    38 allocated buffer of size 188 at ffff88040a84a800
        rpc.nfsd-4720  [001] ....    50.858245: call_bind: RPC:    38 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.858245: call_connect: RPC:    38 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.858245: call_transmit: RPC:    38 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.858245: xprt_prepare_transmit: RPC:    38 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.858246: call_transmit: RPC:    38 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.858246: xprt_transmit: RPC:    38 xprt_transmit(84)
        rpc.nfsd-4720  [001] ....    50.858248: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-4720  [001] ....    50.858248: xprt_transmit: RPC:    38 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.858249: __rpc_sleep_on_priority: RPC:    38 sleep_on(queue "xprt_pending" time 4294904943)
        rpc.nfsd-4720  [001] ..s.    50.858249: __rpc_sleep_on_priority: RPC:    38 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.858249: __rpc_sleep_on_priority: RPC:    38 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.858250: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.858250: __rpc_execute: RPC:    38 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.858257: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.858257: xprt_complete_rqst: RPC:    38 xid 5f45b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.858258: rpc_wake_up_task_queue_locked: RPC:    38 __rpc_wake_up_task (now 4294904943)
         rpcbind-1871  [003] ..s.    50.858258: rpc_wake_up_task_queue_locked: RPC:    38 disabling timer
         rpcbind-1871  [003] ..s.    50.858258: rpc_wake_up_task_queue_locked: RPC:    38 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.858259: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.858260: __rpc_execute: RPC:    38 sync task resuming
        rpc.nfsd-4720  [001] ....    50.858261: call_status: RPC:    38 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.858261: call_decode: RPC:    38 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.858262: call_decode: RPC:    38 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.858262: __rpc_execute: RPC:    38 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.858262: __rpc_execute: RPC:    38 release task
        rpc.nfsd-4720  [001] ....    50.858262: rpc_free: RPC:       freeing buffer of size 188 at ffff88040a84a800
        rpc.nfsd-4720  [001] ....    50.858263: xprt_release: RPC:    38 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.858263: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.858263: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.858264: rpc_free_task: RPC:    38 freeing task
        rpc.nfsd-4720  [001] ....    50.858265: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.858265: rpc_new_task: RPC:       allocated task ffff88040b718200
        rpc.nfsd-4720  [001] ....    50.858265: __rpc_execute: RPC:    39 __rpc_execute flags=0x680
        rpc.nfsd-4720  [001] ....    50.858265: call_start: RPC:    39 call_start rpcbind4 proc SET (sync)
        rpc.nfsd-4720  [001] ....    50.858266: call_reserve: RPC:    39 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.858266: xprt_alloc_slot: RPC:    39 reserved req ffff880403542200 xid 6045b0ec
        rpc.nfsd-4720  [001] ....    50.858266: call_reserveresult: RPC:    39 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.858266: call_refresh: RPC:    39 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.858267: call_refreshresult: RPC:    39 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.858267: call_allocate: RPC:    39 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.858268: rpc_malloc: RPC:    39 allocated buffer of size 188 at ffff88040a84a800
        rpc.nfsd-4720  [001] ....    50.858268: call_bind: RPC:    39 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.858268: call_connect: RPC:    39 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.858268: call_transmit: RPC:    39 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.858269: xprt_prepare_transmit: RPC:    39 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.858269: call_transmit: RPC:    39 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.858269: xprt_transmit: RPC:    39 xprt_transmit(84)
        rpc.nfsd-4720  [001] ....    50.858271: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-4720  [001] ....    50.858272: xprt_transmit: RPC:    39 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.858272: __rpc_sleep_on_priority: RPC:    39 sleep_on(queue "xprt_pending" time 4294904943)
        rpc.nfsd-4720  [001] ..s.    50.858272: __rpc_sleep_on_priority: RPC:    39 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.858272: __rpc_sleep_on_priority: RPC:    39 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.858273: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.858273: __rpc_execute: RPC:    39 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.858280: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.858280: xprt_complete_rqst: RPC:    39 xid 6045b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.858281: rpc_wake_up_task_queue_locked: RPC:    39 __rpc_wake_up_task (now 4294904943)
         rpcbind-1871  [003] ..s.    50.858281: rpc_wake_up_task_queue_locked: RPC:    39 disabling timer
         rpcbind-1871  [003] ..s.    50.858281: rpc_wake_up_task_queue_locked: RPC:    39 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.858282: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.858283: __rpc_execute: RPC:    39 sync task resuming
        rpc.nfsd-4720  [001] ....    50.858284: call_status: RPC:    39 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.858284: call_decode: RPC:    39 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.858285: call_decode: RPC:    39 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.858285: __rpc_execute: RPC:    39 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.858285: __rpc_execute: RPC:    39 release task
        rpc.nfsd-4720  [001] ....    50.858285: rpc_free: RPC:       freeing buffer of size 188 at ffff88040a84a800
        rpc.nfsd-4720  [001] ....    50.858286: xprt_release: RPC:    39 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.858286: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.858286: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.858287: rpc_free_task: RPC:    39 freeing task
        rpc.nfsd-4720  [001] ....    50.858287: svc_write_space: svc: socket ffff8800db81e000(inet ffff8800db8545c0), write_space busy=1
        rpc.nfsd-4720  [001] ....    50.858288: svc_setup_socket: svc: kernel_setsockopt returned 0
        rpc.nfsd-4720  [001] ....    50.858288: svc_setup_socket: svc: svc_setup_socket created ffff8800db81e000 (inet ffff8800db8545c0)
        rpc.nfsd-4720  [001] ....    50.858289: svc_create_socket: svc: svc_create_socket(lockd, 6, 0000:0000:0000:0000:0000:0000:0000:0000, port=0)
        rpc.nfsd-4720  [001] ....    50.858293: svc_setup_socket: svc: svc_setup_socket ffff88040b9d12c0
        rpc.nfsd-4720  [001] ....    50.858295: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.858295: rpc_new_task: RPC:       allocated task ffff88040b718200
        rpc.nfsd-4720  [001] ....    50.858295: __rpc_execute: RPC:    40 __rpc_execute flags=0x680
        rpc.nfsd-4720  [001] ....    50.858296: call_start: RPC:    40 call_start rpcbind4 proc SET (sync)
        rpc.nfsd-4720  [001] ....    50.858296: call_reserve: RPC:    40 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.858296: xprt_alloc_slot: RPC:    40 reserved req ffff880403542200 xid 6145b0ec
        rpc.nfsd-4720  [001] ....    50.858296: call_reserveresult: RPC:    40 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.858297: call_refresh: RPC:    40 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.858297: call_refreshresult: RPC:    40 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.858297: call_allocate: RPC:    40 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.858298: rpc_malloc: RPC:    40 allocated buffer of size 188 at ffff88040a848000
        rpc.nfsd-4720  [001] ....    50.858298: call_bind: RPC:    40 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.858298: call_connect: RPC:    40 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.858299: call_transmit: RPC:    40 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.858299: xprt_prepare_transmit: RPC:    40 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.858299: call_transmit: RPC:    40 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.858300: xprt_transmit: RPC:    40 xprt_transmit(84)
        rpc.nfsd-4720  [001] ....    50.858302: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-4720  [001] ....    50.858302: xprt_transmit: RPC:    40 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.858302: __rpc_sleep_on_priority: RPC:    40 sleep_on(queue "xprt_pending" time 4294904943)
        rpc.nfsd-4720  [001] ..s.    50.858303: __rpc_sleep_on_priority: RPC:    40 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.858303: __rpc_sleep_on_priority: RPC:    40 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.858303: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.858304: __rpc_execute: RPC:    40 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.858310: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.858311: xprt_complete_rqst: RPC:    40 xid 6145b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.858311: rpc_wake_up_task_queue_locked: RPC:    40 __rpc_wake_up_task (now 4294904943)
         rpcbind-1871  [003] ..s.    50.858311: rpc_wake_up_task_queue_locked: RPC:    40 disabling timer
         rpcbind-1871  [003] ..s.    50.858312: rpc_wake_up_task_queue_locked: RPC:    40 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.858313: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.858314: __rpc_execute: RPC:    40 sync task resuming
        rpc.nfsd-4720  [001] ....    50.858314: call_status: RPC:    40 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.858315: call_decode: RPC:    40 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.858315: call_decode: RPC:    40 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.858315: __rpc_execute: RPC:    40 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.858316: __rpc_execute: RPC:    40 release task
        rpc.nfsd-4720  [001] ....    50.858316: rpc_free: RPC:       freeing buffer of size 188 at ffff88040a848000
        rpc.nfsd-4720  [001] ....    50.858316: xprt_release: RPC:    40 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.858317: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.858317: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.858317: rpc_free_task: RPC:    40 freeing task
        rpc.nfsd-4720  [001] ....    50.858318: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.858318: rpc_new_task: RPC:       allocated task ffff88040b718200
        rpc.nfsd-4720  [001] ....    50.858319: __rpc_execute: RPC:    41 __rpc_execute flags=0x680
        rpc.nfsd-4720  [001] ....    50.858319: call_start: RPC:    41 call_start rpcbind4 proc SET (sync)
        rpc.nfsd-4720  [001] ....    50.858319: call_reserve: RPC:    41 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.858320: xprt_alloc_slot: RPC:    41 reserved req ffff880403542200 xid 6245b0ec
        rpc.nfsd-4720  [001] ....    50.858320: call_reserveresult: RPC:    41 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.858320: call_refresh: RPC:    41 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.858320: call_refreshresult: RPC:    41 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.858321: call_allocate: RPC:    41 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.858321: rpc_malloc: RPC:    41 allocated buffer of size 188 at ffff88040a848000
        rpc.nfsd-4720  [001] ....    50.858321: call_bind: RPC:    41 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.858322: call_connect: RPC:    41 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.858322: call_transmit: RPC:    41 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.858322: xprt_prepare_transmit: RPC:    41 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.858322: call_transmit: RPC:    41 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.858323: xprt_transmit: RPC:    41 xprt_transmit(84)
        rpc.nfsd-4720  [001] ....    50.858325: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-4720  [001] ....    50.858325: xprt_transmit: RPC:    41 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.858326: __rpc_sleep_on_priority: RPC:    41 sleep_on(queue "xprt_pending" time 4294904943)
        rpc.nfsd-4720  [001] ..s.    50.858326: __rpc_sleep_on_priority: RPC:    41 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.858326: __rpc_sleep_on_priority: RPC:    41 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.858327: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.858327: __rpc_execute: RPC:    41 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.858333: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.858334: xprt_complete_rqst: RPC:    41 xid 6245b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.858334: rpc_wake_up_task_queue_locked: RPC:    41 __rpc_wake_up_task (now 4294904943)
         rpcbind-1871  [003] ..s.    50.858334: rpc_wake_up_task_queue_locked: RPC:    41 disabling timer
         rpcbind-1871  [003] ..s.    50.858335: rpc_wake_up_task_queue_locked: RPC:    41 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.858336: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.858337: __rpc_execute: RPC:    41 sync task resuming
        rpc.nfsd-4720  [001] ....    50.858337: call_status: RPC:    41 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.858338: call_decode: RPC:    41 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.858338: call_decode: RPC:    41 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.858339: __rpc_execute: RPC:    41 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.858339: __rpc_execute: RPC:    41 release task
        rpc.nfsd-4720  [001] ....    50.858339: rpc_free: RPC:       freeing buffer of size 188 at ffff88040a848000
        rpc.nfsd-4720  [001] ....    50.858339: xprt_release: RPC:    41 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.858340: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.858340: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.858340: rpc_free_task: RPC:    41 freeing task
        rpc.nfsd-4720  [001] ....    50.858341: rpc_new_task: RPC:       new task initialized, procpid 4720
        rpc.nfsd-4720  [001] ....    50.858341: rpc_new_task: RPC:       allocated task ffff88040b718200
        rpc.nfsd-4720  [001] ....    50.858342: __rpc_execute: RPC:    42 __rpc_execute flags=0x680
        rpc.nfsd-4720  [001] ....    50.858342: call_start: RPC:    42 call_start rpcbind4 proc SET (sync)
        rpc.nfsd-4720  [001] ....    50.858343: call_reserve: RPC:    42 call_reserve (status 0)
        rpc.nfsd-4720  [001] ....    50.858343: xprt_alloc_slot: RPC:    42 reserved req ffff880403542200 xid 6345b0ec
        rpc.nfsd-4720  [001] ....    50.858343: call_reserveresult: RPC:    42 call_reserveresult (status 0)
        rpc.nfsd-4720  [001] ....    50.858343: call_refresh: RPC:    42 call_refresh (status 0)
        rpc.nfsd-4720  [001] ....    50.858344: call_refreshresult: RPC:    42 call_refreshresult (status 0)
        rpc.nfsd-4720  [001] ....    50.858344: call_allocate: RPC:    42 call_allocate (status 0)
        rpc.nfsd-4720  [001] ....    50.858344: rpc_malloc: RPC:    42 allocated buffer of size 188 at ffff88040a848000
        rpc.nfsd-4720  [001] ....    50.858344: call_bind: RPC:    42 call_bind (status 0)
        rpc.nfsd-4720  [001] ....    50.858345: call_connect: RPC:    42 call_connect xprt ffff880407939800 is connected
        rpc.nfsd-4720  [001] ....    50.858345: call_transmit: RPC:    42 call_transmit (status 0)
        rpc.nfsd-4720  [001] ....    50.858345: xprt_prepare_transmit: RPC:    42 xprt_prepare_transmit
        rpc.nfsd-4720  [001] ....    50.858345: call_transmit: RPC:    42 rpc_xdr_encode (status 0)
        rpc.nfsd-4720  [001] ....    50.858346: xprt_transmit: RPC:    42 xprt_transmit(84)
        rpc.nfsd-4720  [001] ....    50.858348: xs_local_send_request: RPC:       xs_local_send_request(84) = 0
        rpc.nfsd-4720  [001] ....    50.858348: xprt_transmit: RPC:    42 xmit complete
        rpc.nfsd-4720  [001] ..s.    50.858348: __rpc_sleep_on_priority: RPC:    42 sleep_on(queue "xprt_pending" time 4294904943)
        rpc.nfsd-4720  [001] ..s.    50.858349: __rpc_sleep_on_priority: RPC:    42 added to queue ffff880407939a58 "xprt_pending"
        rpc.nfsd-4720  [001] ..s.    50.858349: __rpc_sleep_on_priority: RPC:    42 setting alarm for 10000 ms
        rpc.nfsd-4720  [001] ..s.    50.858349: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939990 "xprt_sending")
        rpc.nfsd-4720  [001] ....    50.858350: __rpc_execute: RPC:    42 sync task going to sleep
         rpcbind-1871  [003] ..s.    50.858356: xs_local_data_ready: RPC:       xs_local_data_ready...
         rpcbind-1871  [003] ..s.    50.858357: xprt_complete_rqst: RPC:    42 xid 6345b0ec complete (28 bytes received)
         rpcbind-1871  [003] ..s.    50.858357: rpc_wake_up_task_queue_locked: RPC:    42 __rpc_wake_up_task (now 4294904943)
         rpcbind-1871  [003] ..s.    50.858357: rpc_wake_up_task_queue_locked: RPC:    42 disabling timer
         rpcbind-1871  [003] ..s.    50.858358: rpc_wake_up_task_queue_locked: RPC:    42 removed from queue ffff880407939a58 "xprt_pending"
         rpcbind-1871  [003] ..s.    50.858359: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
        rpc.nfsd-4720  [001] ....    50.858360: __rpc_execute: RPC:    42 sync task resuming
        rpc.nfsd-4720  [001] ....    50.858360: call_status: RPC:    42 call_status (status 28)
        rpc.nfsd-4720  [001] ....    50.858361: call_decode: RPC:    42 call_decode (status 28)
        rpc.nfsd-4720  [001] ....    50.858361: call_decode: RPC:    42 call_decode result 0
        rpc.nfsd-4720  [001] ....    50.858361: __rpc_execute: RPC:    42 return 0, status 0
        rpc.nfsd-4720  [001] ....    50.858362: __rpc_execute: RPC:    42 release task
        rpc.nfsd-4720  [001] ....    50.858362: rpc_free: RPC:       freeing buffer of size 188 at ffff88040a848000
        rpc.nfsd-4720  [001] ....    50.858362: xprt_release: RPC:    42 release request ffff880403542200
        rpc.nfsd-4720  [001] ....    50.858363: rpc_wake_up_first: RPC:       wake_up_first(ffff880407939b20 "xprt_backlog")
        rpc.nfsd-4720  [001] ....    50.858363: rpc_release_client: RPC:       rpc_release_client(ffff88040a8b3600)
        rpc.nfsd-4720  [001] ....    50.858363: rpc_free_task: RPC:    42 freeing task
        rpc.nfsd-4720  [001] ....    50.858364: svc_setup_socket: setting up TCP socket for listening
        rpc.nfsd-4720  [001] ....    50.858364: svc_setup_socket: svc: svc_setup_socket created ffff880409d69000 (inet ffff88040a152040)
           lockd-4750  [003] ....    50.858433: svc_write_space: svc: socket ffff8800db83a000(inet ffff88040a14eb80), write_space busy=1
           lockd-4750  [003] ....    50.858435: svc_tcp_accept: svc: tcp_accept ffff88040298e000 sock ffff88040acedd40
           lockd-4750  [003] ....    50.858438: svc_write_space: svc: socket ffff8800db81e000(inet ffff8800db8545c0), write_space busy=1
           lockd-4750  [003] ....    50.858439: svc_tcp_accept: svc: tcp_accept ffff880409d69000 sock ffff88040b9d12c0
            nfsd-4771  [001] ....    50.956508: svc_tcp_accept: svc: tcp_accept ffff880402bd4000 sock ffff8800db68bac0
            nfsd-4772  [003] ....    50.956510: svc_write_space: svc: socket ffff880402ba1000(inet ffff880407b2cc00), write_space busy=1
            nfsd-4772  [003] ....    50.956516: svc_tcp_accept: svc: tcp_accept ffff88040cf94000 sock ffff88040ec230c0
            nfsd-4771  [001] ....    50.956517: svc_write_space: svc: socket ffff880402966000(inet ffff8800db854180), write_space busy=1
          <idle>-0     [003] ..s.   149.227677: svc_tcp_listen_data_ready: svc: socket ffff88040a708780 TCP (listen) state change 10
            nfsd-4779  [003] ....   149.227697: svc_tcp_accept: svc: tcp_accept ffff880402bd4000 sock ffff8800db68bac0
            nfsd-4779  [003] ....   149.227705: svc_tcp_accept: nfsd: connect from 192.168.23.22, port=867
            nfsd-4779  [003] ....   149.227706: svc_setup_socket: svc: svc_setup_socket ffff8804081ad580
            nfsd-4779  [003] ....   149.227708: svc_setup_socket: setting up TCP socket for reading
            nfsd-4779  [003] ....   149.227709: svc_setup_socket: svc: svc_setup_socket created ffff8800daaa1000 (inet ffff8800d8c817c0)
            nfsd-4777  [002] ....   149.227792: svc_tcp_accept: svc: tcp_accept ffff880402bd4000 sock ffff8800db68bac0
            nfsd-4778  [000] ....   149.227792: svc_tcp_recvfrom: svc: tcp_recv ffff8800daaa1000 data 1 conn 0 close 0
            nfsd-4778  [000] ....   149.227797: svc_recvfrom.isra.10: svc: socket ffff8800daaa1000 recvfrom(ffff8800daaa12b8, 4) = -11
            nfsd-4778  [000] ....   149.227798: svc_tcp_recvfrom: RPC: TCP recv_record got -11
            nfsd-4778  [000] ....   149.227798: svc_tcp_recvfrom: RPC: TCP recvfrom got EAGAIN
          <idle>-0     [003] ..s.   149.227933: svc_tcp_data_ready: svc: socket ffff8800d8c817c0 TCP data ready (svsk ffff8800daaa1000)
            nfsd-4779  [003] ....   149.227966: svc_tcp_recvfrom: svc: tcp_recv ffff8800daaa1000 data 1 conn 0 close 0
            nfsd-4779  [003] ....   149.227970: svc_recvfrom.isra.10: svc: socket ffff8800daaa1000 recvfrom(ffff8800daaa12b8, 4) = 4
            nfsd-4779  [003] ....   149.227971: svc_tcp_recvfrom: svc: TCP record, 92 bytes
            nfsd-4779  [003] ....   149.227973: svc_recvfrom.isra.10: svc: socket ffff8800daaa1000 recvfrom(ffff8800dbb8a000, 4096) = 92
            nfsd-4779  [003] ....   149.227974: svc_tcp_fragment_received: svc: TCP final record (92 bytes)
            nfsd-4778  [000] ....   149.228077: svc_tcp_recvfrom: svc: tcp_recv ffff8800daaa1000 data 1 conn 0 close 0
            nfsd-4778  [000] ....   149.228081: svc_recvfrom.isra.10: svc: socket ffff8800daaa1000 recvfrom(ffff8800daaa12b8, 4) = -11
            nfsd-4778  [000] ....   149.228081: svc_tcp_recvfrom: RPC: TCP recv_record got -11
            nfsd-4778  [000] ....   149.228082: svc_tcp_recvfrom: RPC: TCP recvfrom got EAGAIN
            nfsd-4779  [003] ....   149.229024: svc_sendto: svc: socket ffff8800daaa1000 sendto([ffff8800dbb8b000 48... ], 48) = 48 (addr 192.168.23.22, port=867)
          <idle>-0     [003] ..s.   149.229463: svc_tcp_data_ready: svc: socket ffff8800d8c817c0 TCP data ready (svsk ffff8800daaa1000)
            nfsd-4779  [003] ....   149.229481: svc_tcp_recvfrom: svc: tcp_recv ffff8800daaa1000 data 1 conn 0 close 0
            nfsd-4779  [003] ....   149.229484: svc_recvfrom.isra.10: svc: socket ffff8800daaa1000 recvfrom(ffff8800daaa12b8, 4) = 4
            nfsd-4779  [003] ....   149.229485: svc_tcp_recvfrom: svc: TCP record, 184 bytes
            nfsd-4779  [003] ....   149.229487: svc_recvfrom.isra.10: svc: socket ffff8800daaa1000 recvfrom(ffff8800dbb8a000, 4096) = 184
            nfsd-4779  [003] ....   149.229488: svc_tcp_fragment_received: svc: TCP final record (184 bytes)
            nfsd-4779  [003] ....   149.229536: svc_sendto: svc: socket ffff8800daaa1000 sendto([ffff8800d9324000 64... ], 64) = 64 (addr 192.168.23.22, port=867)
            nfsd-4778  [000] ....   149.229558: svc_tcp_recvfrom: svc: tcp_recv ffff8800daaa1000 data 1 conn 0 close 0
            nfsd-4778  [000] ....   149.229562: svc_recvfrom.isra.10: svc: socket ffff8800daaa1000 recvfrom(ffff8800daaa12b8, 4) = -11
            nfsd-4778  [000] ....   149.229562: svc_tcp_recvfrom: RPC: TCP recv_record got -11
            nfsd-4778  [000] ....   149.229563: svc_tcp_recvfrom: RPC: TCP recvfrom got EAGAIN
          <idle>-0     [003] ..s.   149.230009: svc_tcp_data_ready: svc: socket ffff8800d8c817c0 TCP data ready (svsk ffff8800daaa1000)
            nfsd-4779  [003] ....   149.230027: svc_tcp_recvfrom: svc: tcp_recv ffff8800daaa1000 data 1 conn 0 close 0
            nfsd-4779  [003] ....   149.230031: svc_recvfrom.isra.10: svc: socket ffff8800daaa1000 recvfrom(ffff8800daaa12b8, 4) = 4
            nfsd-4779  [003] ....   149.230032: svc_tcp_recvfrom: svc: TCP record, 100 bytes
            nfsd-4779  [003] ....   149.230034: svc_recvfrom.isra.10: svc: socket ffff8800daaa1000 recvfrom(ffff8800dbb8a000, 4096) = 100
            nfsd-4779  [003] ....   149.230035: svc_tcp_fragment_received: svc: TCP final record (100 bytes)
            nfsd-4779  [003] ....   149.230076: svc_sendto: svc: socket ffff8800daaa1000 sendto([ffff88003787b000 48... ], 48) = 48 (addr 192.168.23.22, port=867)
            nfsd-4778  [000] ....   149.230122: svc_tcp_recvfrom: svc: tcp_recv ffff8800daaa1000 data 1 conn 0 close 0
            nfsd-4778  [000] ....   149.230126: svc_recvfrom.isra.10: svc: socket ffff8800daaa1000 recvfrom(ffff8800daaa12b8, 4) = -11
            nfsd-4778  [000] ....   149.230127: svc_tcp_recvfrom: RPC: TCP recv_record got -11
            nfsd-4778  [000] ....   149.230127: svc_tcp_recvfrom: RPC: TCP recvfrom got EAGAIN
   kworker/u32:3-105   [001] ....   149.230132: xs_setup_tcp: RPC:       set up xprt to 192.168.23.22 (port 55201) via tcp
   kworker/u32:3-105   [001] ....   149.230143: xprt_create_transport: RPC:       created transport ffff8800daa83800 with 65536 slots
   kworker/u32:3-105   [001] ....   149.230145: rpc_new_client: RPC:       creating nfs4_cb client for (null) (xprt ffff8800daa83800)
   kworker/u32:3-105   [001] ....   149.230167: rpc_new_task: RPC:       new task initialized, procpid 105
   kworker/u32:3-105   [001] ....   149.230168: rpc_new_task: RPC:       allocated task ffff880408652900
    kworker/1:1H-131   [001] ....   149.230177: __rpc_execute: RPC:    43 __rpc_execute flags=0x681
    kworker/1:1H-131   [001] ....   149.230179: call_start: RPC:    43 call_start nfs4_cb1 proc CB_NULL (async)
    kworker/1:1H-131   [001] ....   149.230180: call_reserve: RPC:    43 call_reserve (status 0)
    kworker/1:1H-131   [001] ....   149.230183: xprt_alloc_slot: RPC:    43 reserved req ffff8800daa7f000 xid 2f21bdb9
    kworker/1:1H-131   [001] ..s.   149.230184: rpc_wake_up_first: RPC:       wake_up_first(ffff8800daa83990 "xprt_sending")
    kworker/1:1H-131   [001] ....   149.230185: call_reserveresult: RPC:    43 call_reserveresult (status 0)
    kworker/1:1H-131   [001] ....   149.230186: call_refresh: RPC:    43 call_refresh (status 0)
    kworker/1:1H-131   [001] ....   149.230189: call_refreshresult: RPC:    43 call_refreshresult (status 0)
    kworker/1:1H-131   [001] ....   149.230190: call_allocate: RPC:    43 call_allocate (status 0)
    kworker/1:1H-131   [001] ....   149.230192: rpc_malloc: RPC:    43 allocated buffer of size 396 at ffff8800daafc000
    kworker/1:1H-131   [001] ....   149.230192: call_bind: RPC:    43 call_bind (status 0)
    kworker/1:1H-131   [001] ....   149.230194: call_connect: RPC:    43 call_connect xprt ffff8800daa83800 is not connected
    kworker/1:1H-131   [001] ....   149.230195: xprt_connect: RPC:    43 xprt_connect xprt ffff8800daa83800 is not connected
    kworker/1:1H-131   [001] ..s.   149.230196: __rpc_sleep_on_priority: RPC:    43 sleep_on(queue "xprt_pending" time 4294929524)
    kworker/1:1H-131   [001] ..s.   149.230197: __rpc_sleep_on_priority: RPC:    43 added to queue ffff8800daa83a58 "xprt_pending"
    kworker/1:1H-131   [001] ..s.   149.230198: __rpc_sleep_on_priority: RPC:    43 setting alarm for 9000 ms
    kworker/1:1H-131   [001] ....   149.230201: xs_connect: RPC:       xs_connect scheduled xprt ffff8800daa83800
    kworker/1:1H-131   [001] ..s.   149.230212: inet_csk_get_port: kworker/1:1H:131 got port 947
    kworker/1:1H-131   [001] ....   149.230274: xs_bind: RPC:       xs_bind 0.0.0.0:947: ok (0)
    kworker/1:1H-131   [001] ....   149.230276: xs_tcp_setup_socket: RPC:       worker connecting xprt ffff8800daa83800 via tcp to 192.168.23.22 (port 55201)
    kworker/1:1H-131   [001] ....   149.230310: xs_tcp_setup_socket: RPC:       ffff8800daa83800 connect status 115 connected 0 sock state 2
    kworker/1:1H-131   [001] ..s.   149.230312: rpc_wake_up_first: RPC:       wake_up_first(ffff8800daa83990 "xprt_sending")
          <idle>-0     [003] ..s.   149.230583: xs_tcp_state_change: RPC:       xs_tcp_state_change client ffff8800daa83800...
          <idle>-0     [003] ..s.   149.230585: xs_tcp_state_change: RPC:       state 1 conn 0 dead 0 zapped 1 sk_shutdown 0
          <idle>-0     [003] ..s.   149.230587: rpc_wake_up_task_queue_locked: RPC:    43 __rpc_wake_up_task (now 4294929525)
          <idle>-0     [003] ..s.   149.230587: rpc_wake_up_task_queue_locked: RPC:    43 disabling timer
          <idle>-0     [003] ..s.   149.230588: rpc_wake_up_task_queue_locked: RPC:    43 removed from queue ffff8800daa83a58 "xprt_pending"
          <idle>-0     [003] .Ns.   149.230592: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
    kworker/3:1H-124   [003] ....   149.230618: __rpc_execute: RPC:    43 __rpc_execute flags=0x681
    kworker/3:1H-124   [003] ....   149.230619: xprt_connect_status: RPC:    43 xprt_connect_status: retrying
    kworker/3:1H-124   [003] ....   149.230621: call_connect_status: RPC:    43 call_connect_status (status -11)
    kworker/3:1H-124   [003] ....   149.230622: call_timeout: RPC:    43 call_timeout (minor)
    kworker/3:1H-124   [003] ....   149.230623: call_bind: RPC:    43 call_bind (status 0)
    kworker/3:1H-124   [003] ....   149.230624: call_connect: RPC:    43 call_connect xprt ffff8800daa83800 is connected
    kworker/3:1H-124   [003] ....   149.230625: call_transmit: RPC:    43 call_transmit (status 0)
    kworker/3:1H-124   [003] ....   149.230625: xprt_prepare_transmit: RPC:    43 xprt_prepare_transmit
    kworker/3:1H-124   [003] ....   149.230626: call_transmit: RPC:    43 rpc_xdr_encode (status 0)
    kworker/3:1H-124   [003] ....   149.230629: xprt_transmit: RPC:    43 xprt_transmit(72)
    kworker/3:1H-124   [003] ....   149.230644: xs_tcp_send_request: RPC:       xs_tcp_send_request(72) = 0
    kworker/3:1H-124   [003] ....   149.230644: xprt_transmit: RPC:    43 xmit complete
    kworker/3:1H-124   [003] ..s.   149.230645: __rpc_sleep_on_priority: RPC:    43 sleep_on(queue "xprt_pending" time 4294929525)
    kworker/3:1H-124   [003] ..s.   149.230646: __rpc_sleep_on_priority: RPC:    43 added to queue ffff8800daa83a58 "xprt_pending"
    kworker/3:1H-124   [003] ..s.   149.230647: __rpc_sleep_on_priority: RPC:    43 setting alarm for 9000 ms
    kworker/3:1H-124   [003] ..s.   149.230649: rpc_wake_up_first: RPC:       wake_up_first(ffff8800daa83990 "xprt_sending")
          <idle>-0     [003] ..s.   149.230989: xs_tcp_data_ready: RPC:       xs_tcp_data_ready...
          <idle>-0     [003] ..s.   149.230990: xs_tcp_data_recv: RPC:       xs_tcp_data_recv started
          <idle>-0     [003] ..s.   149.230992: xs_tcp_data_recv: RPC:       reading TCP record fragment of length 24
          <idle>-0     [003] ..s.   149.230992: xs_tcp_data_recv: RPC:       reading XID (4 bytes)
          <idle>-0     [003] ..s.   149.230994: xs_tcp_data_recv: RPC:       reading request with XID 2f21bdb9
          <idle>-0     [003] ..s.   149.230995: xs_tcp_data_recv: RPC:       reading CALL/REPLY flag (4 bytes)
          <idle>-0     [003] ..s.   149.230995: xs_tcp_data_recv: RPC:       read reply XID 2f21bdb9
          <idle>-0     [003] ..s.   149.230997: xs_tcp_data_recv: RPC:       XID 2f21bdb9 read 16 bytes
          <idle>-0     [003] ..s.   149.230998: xs_tcp_data_recv: RPC:       xprt = ffff8800daa83800, tcp_copied = 24, tcp_offset = 24, tcp_reclen = 24
          <idle>-0     [003] ..s.   149.230999: xprt_complete_rqst: RPC:    43 xid 2f21bdb9 complete (24 bytes received)
          <idle>-0     [003] ..s.   149.231000: rpc_wake_up_task_queue_locked: RPC:    43 __rpc_wake_up_task (now 4294929525)
          <idle>-0     [003] ..s.   149.231000: rpc_wake_up_task_queue_locked: RPC:    43 disabling timer
          <idle>-0     [003] ..s.   149.231002: rpc_wake_up_task_queue_locked: RPC:    43 removed from queue ffff8800daa83a58 "xprt_pending"
          <idle>-0     [003] .Ns.   149.231004: rpc_wake_up_task_queue_locked: RPC:       __rpc_wake_up_task done
          <idle>-0     [003] .Ns.   149.231005: xs_tcp_data_recv: RPC:       xs_tcp_data_recv done
    kworker/3:1H-124   [003] ....   149.231016: __rpc_execute: RPC:    43 __rpc_execute flags=0xe81
    kworker/3:1H-124   [003] ....   149.231017: call_status: RPC:    43 call_status (status 24)
    kworker/3:1H-124   [003] ....   149.231018: call_decode: RPC:    43 call_decode (status 24)
    kworker/3:1H-124   [003] ....   149.231020: call_decode: RPC:    43 call_decode result 0
    kworker/3:1H-124   [003] ....   149.231021: __rpc_execute: RPC:    43 return 0, status 0
    kworker/3:1H-124   [003] ....   149.231022: __rpc_execute: RPC:    43 release task
    kworker/3:1H-124   [003] ....   149.231024: rpc_free: RPC:       freeing buffer of size 396 at ffff8800daafc000
    kworker/3:1H-124   [003] ....   149.231025: xprt_release: RPC:    43 release request ffff8800daa7f000
    kworker/3:1H-124   [003] ....   149.231026: rpc_wake_up_first: RPC:       wake_up_first(ffff8800daa83b20 "xprt_backlog")
    kworker/3:1H-124   [003] ....   149.231027: rpc_release_client: RPC:       rpc_release_client(ffff8800daa7f800)
    kworker/3:1H-124   [003] ....   149.231028: rpc_free_task: RPC:    43 freeing task
          <idle>-0     [000] ..s.   154.237735: svc_tcp_data_ready: svc: socket ffff8800d8c817c0 TCP data ready (svsk ffff8800daaa1000)
            nfsd-4779  [003] ....   154.237808: svc_tcp_recvfrom: svc: tcp_recv ffff8800daaa1000 data 1 conn 0 close 0
            nfsd-4779  [003] ....   154.237814: svc_recvfrom.isra.10: svc: socket ffff8800daaa1000 recvfrom(ffff8800daaa12b8, 4) = 4
            nfsd-4779  [003] ....   154.237815: svc_tcp_recvfrom: svc: TCP record, 92 bytes
            nfsd-4779  [003] ....   154.237818: svc_recvfrom.isra.10: svc: socket ffff8800daaa1000 recvfrom(ffff8800dbb8a000, 4096) = 92
            nfsd-4779  [003] ....   154.237819: svc_tcp_fragment_received: svc: TCP final record (92 bytes)
            nfsd-4779  [003] ....   154.237872: svc_sendto: svc: socket ffff8800daaa1000 sendto([ffff8800d9324000 48... ], 48) = 48 (addr 192.168.23.22, port=867)
            nfsd-4778  [000] ....   154.237892: svc_tcp_recvfrom: svc: tcp_recv ffff8800daaa1000 data 1 conn 0 close 0
            nfsd-4778  [000] ....   154.237896: svc_recvfrom.isra.10: svc: socket ffff8800daaa1000 recvfrom(ffff8800daaa12b8, 4) = -11
            nfsd-4778  [000] ....   154.237897: svc_tcp_recvfrom: RPC: TCP recv_record got -11
            nfsd-4778  [000] ....   154.237897: svc_tcp_recvfrom: RPC: TCP recvfrom got EAGAIN
          <idle>-0     [001] ..s.   214.282477: svc_tcp_data_ready: svc: socket ffff8800d8c817c0 TCP data ready (svsk ffff8800daaa1000)
            nfsd-4779  [003] ....   214.282554: svc_tcp_recvfrom: svc: tcp_recv ffff8800daaa1000 data 1 conn 0 close 0
            nfsd-4779  [003] ....   214.282559: svc_recvfrom.isra.10: svc: socket ffff8800daaa1000 recvfrom(ffff8800daaa12b8, 4) = 4
            nfsd-4779  [003] ....   214.282560: svc_tcp_recvfrom: svc: TCP record, 92 bytes
            nfsd-4779  [003] ....   214.282563: svc_recvfrom.isra.10: svc: socket ffff8800daaa1000 recvfrom(ffff8800dbb8a000, 4096) = 92
            nfsd-4779  [003] ....   214.282564: svc_tcp_fragment_received: svc: TCP final record (92 bytes)
            nfsd-4779  [003] ....   214.282617: svc_sendto: svc: socket ffff8800daaa1000 sendto([ffff8804086ca000 48... ], 48) = 48 (addr 192.168.23.22, port=867)
            nfsd-4778  [000] ....   214.282637: svc_tcp_recvfrom: svc: tcp_recv ffff8800daaa1000 data 1 conn 0 close 0
            nfsd-4778  [000] ....   214.282642: svc_recvfrom.isra.10: svc: socket ffff8800daaa1000 recvfrom(ffff8800daaa12b8, 4) = -11
            nfsd-4778  [000] ....   214.282643: svc_tcp_recvfrom: RPC: TCP recv_record got -11
            nfsd-4778  [000] ....   214.282643: svc_tcp_recvfrom: RPC: TCP recvfrom got EAGAIN
    spamassassin-5827  [000] ..s.   274.471016: svc_tcp_data_ready: svc: socket ffff8800d8c817c0 TCP data ready (svsk ffff8800daaa1000)
            nfsd-4779  [003] ....   274.471080: svc_tcp_recvfrom: svc: tcp_recv ffff8800daaa1000 data 1 conn 0 close 0
            nfsd-4779  [003] ....   274.471085: svc_recvfrom.isra.10: svc: socket ffff8800daaa1000 recvfrom(ffff8800daaa12b8, 4) = 4
            nfsd-4779  [003] ....   274.471085: svc_tcp_recvfrom: svc: TCP record, 92 bytes
            nfsd-4779  [003] ....   274.471087: svc_recvfrom.isra.10: svc: socket ffff8800daaa1000 recvfrom(ffff8800dbb8a000, 4096) = 92
            nfsd-4779  [003] ....   274.471088: svc_tcp_fragment_received: svc: TCP final record (92 bytes)
            nfsd-4779  [003] ....   274.471130: svc_sendto: svc: socket ffff8800daaa1000 sendto([ffff88040a6dd000 48... ], 48) = 48 (addr 192.168.23.22, port=867)
            nfsd-4778  [001] ....   274.471134: svc_tcp_recvfrom: svc: tcp_recv ffff8800daaa1000 data 1 conn 0 close 0
            nfsd-4778  [001] ....   274.471136: svc_recvfrom.isra.10: svc: socket ffff8800daaa1000 recvfrom(ffff8800daaa12b8, 4) = -11
            nfsd-4778  [001] ....   274.471136: svc_tcp_recvfrom: RPC: TCP recv_record got -11
            nfsd-4778  [001] ....   274.471137: svc_tcp_recvfrom: RPC: TCP recvfrom got EAGAIN
          <idle>-0     [000] .Ns.   334.659832: svc_tcp_data_ready: svc: socket ffff8800d8c817c0 TCP data ready (svsk ffff8800daaa1000)
            nfsd-4779  [003] ....   334.659927: svc_tcp_recvfrom: svc: tcp_recv ffff8800daaa1000 data 1 conn 0 close 0
            nfsd-4779  [003] ....   334.659933: svc_recvfrom.isra.10: svc: socket ffff8800daaa1000 recvfrom(ffff8800daaa12b8, 4) = 4
            nfsd-4779  [003] ....   334.659934: svc_tcp_recvfrom: svc: TCP record, 92 bytes
            nfsd-4779  [003] ....   334.659937: svc_recvfrom.isra.10: svc: socket ffff8800daaa1000 recvfrom(ffff8800dbb8a000, 4096) = 92
            nfsd-4779  [003] ....   334.659938: svc_tcp_fragment_received: svc: TCP final record (92 bytes)
            nfsd-4778  [001] ....   334.659952: svc_tcp_recvfrom: svc: tcp_recv ffff8800daaa1000 data 1 conn 0 close 0
            nfsd-4778  [001] ....   334.659957: svc_recvfrom.isra.10: svc: socket ffff8800daaa1000 recvfrom(ffff8800daaa12b8, 4) = -11
            nfsd-4778  [001] ....   334.659957: svc_tcp_recvfrom: RPC: TCP recv_record got -11
            nfsd-4778  [001] ....   334.659958: svc_tcp_recvfrom: RPC: TCP recvfrom got EAGAIN
            nfsd-4779  [003] ....   334.659991: svc_sendto: svc: socket ffff8800daaa1000 sendto([ffff88040a043000 48... ], 48) = 48 (addr 192.168.23.22, port=867)
          <idle>-0     [003] ..s.   394.848497: svc_tcp_data_ready: svc: socket ffff8800d8c817c0 TCP data ready (svsk ffff8800daaa1000)
            nfsd-4779  [003] ....   394.848520: svc_tcp_recvfrom: svc: tcp_recv ffff8800daaa1000 data 1 conn 0 close 0
            nfsd-4779  [003] ....   394.848524: svc_recvfrom.isra.10: svc: socket ffff8800daaa1000 recvfrom(ffff8800daaa12b8, 4) = 4
            nfsd-4779  [003] ....   394.848525: svc_tcp_recvfrom: svc: TCP record, 92 bytes
            nfsd-4779  [003] ....   394.848527: svc_recvfrom.isra.10: svc: socket ffff8800daaa1000 recvfrom(ffff8800dbb8a000, 4096) = 92
            nfsd-4779  [003] ....   394.848528: svc_tcp_fragment_received: svc: TCP final record (92 bytes)
            nfsd-4779  [003] ....   394.848579: svc_sendto: svc: socket ffff8800daaa1000 sendto([ffff880402bc9000 48... ], 48) = 48 (addr 192.168.23.22, port=867)
            nfsd-4778  [001] ....   394.848599: svc_tcp_recvfrom: svc: tcp_recv ffff8800daaa1000 data 1 conn 0 close 0
            nfsd-4778  [001] ....   394.848603: svc_recvfrom.isra.10: svc: socket ffff8800daaa1000 recvfrom(ffff8800daaa12b8, 4) = -11
            nfsd-4778  [001] ....   394.848604: svc_tcp_recvfrom: RPC: TCP recv_record got -11
            nfsd-4778  [001] ....   394.848604: svc_tcp_recvfrom: RPC: TCP recvfrom got EAGAIN
    kworker/3:1H-124   [003] ..s.   449.959363: xs_tcp_state_change: RPC:       xs_tcp_state_change client ffff8800daa83800...
    kworker/3:1H-124   [003] ..s.   449.959366: xs_tcp_state_change: RPC:       state 4 conn 1 dead 0 zapped 1 sk_shutdown 3
    kworker/3:1H-124   [003] ..s.   449.959369: rpc_wake_up_first: RPC:       wake_up_first(ffff8800daa83990 "xprt_sending")
          <idle>-0     [000] ..s.   449.959669: xs_tcp_state_change: RPC:       xs_tcp_state_change client ffff8800daa83800...
          <idle>-0     [000] ..s.   449.959671: xs_tcp_state_change: RPC:       state 5 conn 0 dead 0 zapped 1 sk_shutdown 3
          <idle>-0     [000] ..s.   449.959693: xs_tcp_state_change: RPC:       xs_tcp_state_change client ffff8800daa83800...
          <idle>-0     [000] ..s.   449.959694: xs_tcp_state_change: RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
          <idle>-0     [000] ..s.   449.959695: xprt_disconnect_done: RPC:       disconnected transport ffff8800daa83800
          <idle>-0     [000] ..s.   449.959696: xs_tcp_state_change: RPC:       xs_tcp_state_change client ffff8800daa83800...
          <idle>-0     [000] ..s.   449.959696: xs_tcp_state_change: RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
          <idle>-0     [000] ..s.   449.959697: xprt_disconnect_done: RPC:       disconnected transport ffff8800daa83800
          <idle>-0     [000] ..s.   449.959698: xs_tcp_data_ready: RPC:       xs_tcp_data_ready...
          <idle>-0     [003] ..s.   455.037231: svc_tcp_data_ready: svc: socket ffff8800d8c817c0 TCP data ready (svsk ffff8800daaa1000)
            nfsd-4779  [003] ....   455.037253: svc_tcp_recvfrom: svc: tcp_recv ffff8800daaa1000 data 1 conn 0 close 0
            nfsd-4779  [003] ....   455.037267: svc_recvfrom.isra.10: svc: socket ffff8800daaa1000 recvfrom(ffff8800daaa12b8, 4) = 4
            nfsd-4779  [003] ....   455.037268: svc_tcp_recvfrom: svc: TCP record, 92 bytes
            nfsd-4779  [003] ....   455.037270: svc_recvfrom.isra.10: svc: socket ffff8800daaa1000 recvfrom(ffff8800dbb8a000, 4096) = 92
            nfsd-4779  [003] ....   455.037272: svc_tcp_fragment_received: svc: TCP final record (92 bytes)
            nfsd-4779  [003] ....   455.037313: svc_sendto: svc: socket ffff8800daaa1000 sendto([ffff880408502000 48... ], 48) = 48 (addr 192.168.23.22, port=867)
            nfsd-4778  [001] ....   455.037340: svc_tcp_recvfrom: svc: tcp_recv ffff8800daaa1000 data 1 conn 0 close 0
            nfsd-4778  [001] ....   455.037345: svc_recvfrom.isra.10: svc: socket ffff8800daaa1000 recvfrom(ffff8800daaa12b8, 4) = -11
            nfsd-4778  [001] ....   455.037346: svc_tcp_recvfrom: RPC: TCP recv_record got -11
            nfsd-4778  [001] ....   455.037347: svc_tcp_recvfrom: RPC: TCP recvfrom got EAGAIN
          <idle>-0     [002] ..s.   515.225890: svc_tcp_data_ready: svc: socket ffff8800d8c817c0 TCP data ready (svsk ffff8800daaa1000)
            nfsd-4779  [002] ....   515.225914: svc_tcp_recvfrom: svc: tcp_recv ffff8800daaa1000 data 1 conn 0 close 0
            nfsd-4779  [002] ....   515.225918: svc_recvfrom.isra.10: svc: socket ffff8800daaa1000 recvfrom(ffff8800daaa12b8, 4) = 4
            nfsd-4779  [002] ....   515.225919: svc_tcp_recvfrom: svc: TCP record, 92 bytes
            nfsd-4779  [002] ....   515.225921: svc_recvfrom.isra.10: svc: socket ffff8800daaa1000 recvfrom(ffff8800dbb8a000, 4096) = 92
            nfsd-4779  [002] ....   515.225922: svc_tcp_fragment_received: svc: TCP final record (92 bytes)
            nfsd-4779  [002] ....   515.225972: svc_sendto: svc: socket ffff8800daaa1000 sendto([ffff8800d8cab000 48... ], 48) = 48 (addr 192.168.23.22, port=867)
            nfsd-4778  [001] ....   515.225990: svc_tcp_recvfrom: svc: tcp_recv ffff8800daaa1000 data 1 conn 0 close 0
            nfsd-4778  [001] ....   515.225995: svc_recvfrom.isra.10: svc: socket ffff8800daaa1000 recvfrom(ffff8800daaa12b8, 4) = -11
            nfsd-4778  [001] ....   515.225995: svc_tcp_recvfrom: RPC: TCP recv_record got -11
            nfsd-4778  [001] ....   515.225996: svc_tcp_recvfrom: RPC: TCP recvfrom got EAGAIN

I don't see that 55201 anywhere. But then again, I didn't look for it
before the port disappeared. I could reboot and look for it again. I
should have saved the full netstat -tapn as well :-/

Oh well, I'll do this again (saving all the info and also netstat)

-- Steve

--MP_/uz8ubrnLjlLeVfoWsN_3=99
Content-Type: text/x-patch
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=debug-nfs.patch

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 3e44b9b0b78e..90cc377388b4 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -225,6 +225,9 @@ tb_not_found:
 			tb->fastreuseport = 0;
 	}
 success:
+	if (!current->mm)
+		trace_printk("%s:%d got port %d\n", current->comm, current->pid,
+			     snum);
 	if (!inet_csk(sk)->icsk_bind_hash)
 		inet_bind_hash(sk, tb, snum);
 	WARN_ON(inet_csk(sk)->icsk_bind_hash != tb);
diff --git a/net/sunrpc/sunrpc.h b/net/sunrpc/sunrpc.h
index f2b7cb540e61..8ea4ddaed8b3 100644
--- a/net/sunrpc/sunrpc.h
+++ b/net/sunrpc/sunrpc.h
@@ -29,6 +29,12 @@ SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 #include <linux/net.h>
 
+#undef dprintk
+#undef dprintk_rcu
+
+#define dprintk(args...)	trace_printk(args)
+#define dprintk_rcu(args...)	trace_printk(args)
+
 /*
  * Header for dynamically allocated rpc buffers.
  */

--MP_/uz8ubrnLjlLeVfoWsN_3=99--

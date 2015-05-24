From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net] ipv4: Avoid crashing in ip_error
Date: Sun, 24 May 2015 13:52:35 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1505240858440.1473@ja.home.ssi.bg>
References: <2b6d6ab2d8c35af3be55c82e507f5376@vittgam.net>  <20150520025428.GA23304@kroah.com>  <b5abf7328b22373e4ec18bd6da479431@vittgam.net>  <06f5f10e9ee831f5a839c6ea24b94f64@vittgam.net>  <d146b8b8a69462ced89a384e6be85b28@vittgam.net>
 <4cb068397127c2b2baee1f021b014b11@vittgam.net>  <da006bc9072931406270f0fdda06045d@vittgam.net>  <6056363be65a2c129551518da94bff20@vittgam.net>  <87a8wx97er.fsf@x220.int.ebiederm.org>  <ff82713d6862786de9784bd3c9c06bfa@vittgam.net>  <20150522040453.GC8530@1wt.eu>
 <87zj4x6iiz.fsf_-_@x220.int.ebiederm.org>  <alpine.LFD.2.11.1505231158240.1796@ja.home.ssi.bg>  <87oalb2w8l.fsf@x220.int.ebiederm.org>  <alpine.LFD.2.11.1505232131230.1796@ja.home.ssi.bg> <1432415349.4060.136.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"Vittorio G (VittGam)" <linuxbugs@vittgam.net>,
	security@kernel.org, Greg KH <greg@kroah.com>, luto@amacapital.net,
	Willy Tarreau <w@1wt.eu>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:46523 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751063AbbEXKxT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 May 2015 06:53:19 -0400
In-Reply-To: <1432415349.4060.136.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sat, 23 May 2015, Eric Dumazet wrote:

> > 	Not sure if that can help but both RCU_INIT_POINTER
> > calls in veth_dellink can be before the unregister_netdevice_queue
> > ones. May be it will help for the case when veth_dellink is
> > called with head=NULL. As result, veth_xmit will free all
> > flying skbs to peer that is unregistered first.
> 
> Good point, but note that we never call dellink() method with head==NULL
> in current kernels.

	Can it be a general problem with process_backlog
delivering packets even after the ndo_stop call?
It can happen even for devices that use napi_disable.
synchronize_net simply misses packets processed on
another CPU because process_backlog is not always in
RCU read section.

	What about moving flush_backlog before
NETDEV_UNREGISTER, it was after NETDEV_UNREGISTER_FINAL.
It will work like a synchronize_net call.

rollback_registered_many:
1. __dev_close_many: Commit netif_running, ndo_stop
2. on_each_cpu(flush_backlog, dev, 1): may be its place
can be additionally tuned...
3. synchronize_net: not needed anymore?
4. call_netdevice_notifiers(NETDEV_UNREGISTER, dev)

Compile-tested only:

diff --git a/net/core/dev.c b/net/core/dev.c
index c7ba038..e402661 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6034,6 +6036,7 @@ static void rollback_registered_many(struct list_head *head)
 		unlist_netdevice(dev);
 
 		dev->reg_state = NETREG_UNREGISTERING;
+		on_each_cpu(flush_backlog, dev, 1);
 	}
 
 	synchronize_net();
@@ -6657,8 +6660,6 @@ void netdev_run_todo(void)
 
 		dev->reg_state = NETREG_UNREGISTERED;
 
-		on_each_cpu(flush_backlog, dev, 1);
-
 		netdev_wait_allrefs(dev);
 
 		/* paranoia */
Regards

--
Julian Anastasov <ja@ssi.bg>

From: Thomas Huth <thuth@linux.vnet.ibm.com>
Subject: Re: macvtap bug: using smp_processor_id() in preemptible code
Date: Thu, 8 Aug 2013 10:25:51 +0200
Message-ID: <20130808102551.6aa47852@thhw500>
References: <20130807164319.20aa2333@thhw500>
	<1375889211.4004.28.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Vlad Yasevich <vyasevic@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp13.uk.ibm.com ([195.75.94.109]:42900 "EHLO
	e06smtp13.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756317Ab3HHIZ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 04:25:58 -0400
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <thuth@linux.vnet.ibm.com>;
	Thu, 8 Aug 2013 09:20:58 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 1530E219005E
	for <netdev@vger.kernel.org>; Thu,  8 Aug 2013 09:30:20 +0100 (BST)
Received: from d06av12.portsmouth.uk.ibm.com (d06av12.portsmouth.uk.ibm.com [9.149.37.247])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r788PfcA65798262
	for <netdev@vger.kernel.org>; Thu, 8 Aug 2013 08:25:41 GMT
Received: from d06av12.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av12.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r788PphU029154
	for <netdev@vger.kernel.org>; Thu, 8 Aug 2013 02:25:52 -0600
In-Reply-To: <1375889211.4004.28.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 Hi,

Am Wed, 07 Aug 2013 08:26:51 -0700
schrieb Eric Dumazet <eric.dumazet@gmail.com>:

> On Wed, 2013-08-07 at 16:43 +0200, Thomas Huth wrote:
> > 
> > I am using macvtap (via KVM/virsh) on a s390 box. With the latest
> > kernel source from linux-next master branch, I suddenly get the
> > following error messages in the dmesg output:
> > 
> > BUG: using smp_processor_id() in preemptible [00000000] code: vhost-45891/45892
> > caller is macvtap_do_read+0x45c/0x600 [macvtap]
> > CPU: 1 PID: 45892 Comm: vhost-45891 Not tainted 3.11.0-bisecttest #13
> >        000000010cab3a00 000000010cab3a10 0000000000000002 0000000000000000 
> >        000000010cab3aa0 000000010cab3a18 000000010cab3a18 00000000001127b4 
> >        0000000000000000 0000000000000001 0000000000000000 000000010000000b 
> >        0000000000000060 000003fe00000008 0000000000000000 000000010cab3a70 
> >        00000000006ea2f0 00000000001127b4 000000010cab3a00 000000010cab3a50 
> > Call Trace:
> > ([<00000000001126ee>] show_trace+0x126/0x144)
> >  [<00000000001127d2>] show_stack+0xc6/0xd4
> >  [<000000000068bcec>] dump_stack+0x74/0xd8
> >  [<0000000000481066>] debug_smp_processor_id+0xf6/0x114
> >  [<000003ff802e9a18>] macvtap_do_read+0x45c/0x600 [macvtap]
> >  [<000003ff802e9c1c>] macvtap_recvmsg+0x60/0x88 [macvtap]
> >  [<000003ff80318c5e>] handle_rx+0x5b2/0x800 [vhost_net]
> >  [<000003ff8028f77c>] vhost_worker+0x15c/0x1c4 [vhost]
> >  [<000000000015f3ac>] kthread+0xd8/0xe4
> >  [<00000000006934a6>] kernel_thread_starter+0x6/0xc
> >  [<00000000006934a0>] kernel_thread_starter+0x0/0xc
> > 2 locks held by vhost-45891/45892:
> >  #0:  (&vq->mutex){+.+...}, at: [<000003ff80318718>] handle_rx+0x6c/0x800 [vhost_net]
> >  #1:  (rcu_read_lock){.+.+..}, at: [<000003ff802e98fe>] macvtap_do_read+0x342/0x600 [macvtap]
> > 
> > Apart from these "annoying" error messages (they are repeated
> > continually while the KVM guest is running / macvtap is in use),
> > everything still seems to work fine, though.
> > 
> > Since everything was still working fine in v3.10, I did some bisecting
> > and it seems like this commit introduced this problem:
> > 
> >   commit: ac4e4af1e59e16a018527ffa58d9d3f30bb96ca9
> >   Subject: macvtap: Consistently use rcu functions
> > 
> > I am not sure how to proceed here, this is my first bug report in this
> > area, so advice is welcome...
> 
> Please try following fix :
> 
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index a98fb0e..1c7aab4 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -912,8 +912,11 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
>  done:
>  	rcu_read_lock();
>  	vlan = rcu_dereference(q->vlan);
> -	if (vlan)
> +	if (vlan) {
> +		preempt_disable();
>  		macvlan_count_rx(vlan, copied - vnet_hdr_len, ret == 0, 0);
> +		preempt_enable();
> +	}
>  	rcu_read_unlock();
> 
>  	return ret ? ret : copied;

Thank you very much for your fast reply and the fix, it indeed fixes
the messages about macvtap_do_read!
However, I now noticed that there are more messages, which I just did
not see before because my dmesg output was already flooded with the
messages about macvtap_do_read. The other messages are all about
macvlan_start_xmit:

BUG: using smp_processor_id() in preemptible [00000000] code: vhost-45897/45898
caller is macvlan_start_xmit+0x10a/0x1b4 [macvlan]
CPU: 1 PID: 45898 Comm: vhost-45897 Not tainted 3.11.0-bisecttest #16
       00000001189b3960 00000001189b3970 0000000000000002 0000000000000000 
       00000001189b3a00 00000001189b3978 00000001189b3978 00000000001127b4 
       0000000000000000 0000000000000001 0000000000000000 000000000000000b 
       0000000000000060 000003fe00000008 0000000000000000 00000001189b39d0 
       00000000006ea2f0 00000000001127b4 00000001189b3960 00000001189b39b0 
Call Trace:
([<00000000001126ee>] show_trace+0x126/0x144)
 [<00000000001127d2>] show_stack+0xc6/0xd4
 [<000000000068bdb8>] dump_stack+0x74/0xd4
 [<0000000000481132>] debug_smp_processor_id+0xf6/0x114
 [<000003ff802b72ca>] macvlan_start_xmit+0x10a/0x1b4 [macvlan]
 [<000003ff802ea69a>] macvtap_get_user+0x982/0xbc4 [macvtap]
 [<000003ff802ea92a>] macvtap_sendmsg+0x4e/0x60 [macvtap]
 [<000003ff8031947c>] handle_tx+0x494/0x5ec [vhost_net]
 [<000003ff8028f77c>] vhost_worker+0x15c/0x1c4 [vhost]
 [<000000000015f3ac>] kthread+0xd8/0xe4
 [<000000000069356e>] kernel_thread_starter+0x6/0xc
 [<0000000000693568>] kernel_thread_starter+0x0/0xc
2 locks held by vhost-45897/45898:
 #0:  (&vq->mutex){+.+.+.}, at: [<000003ff8031903c>] handle_tx+0x54/0x5ec [vhost_net]
 #1:  (rcu_read_lock){.+.+..}, at: [<000003ff802ea53c>] macvtap_get_user+0x824/0xbc4 [macvtap]

Do you also have got an idea how to silence these messages?

 Thomas

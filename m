From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: Re: low latency/busy poll feedback and bugs
Date: Tue, 6 Aug 2013 13:08:06 -0500
Message-ID: <20130806180806.GA8993@sbohrermbp13-local.rgmadvisors.com>
References: <20130805212257.GB6904@sbohrermbp13-local.rgmadvisors.com>
 <5200A8BC.4010402@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog105.obsmtp.com ([74.125.149.75]:37611 "EHLO
	na3sys009aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756270Ab3HFSIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 14:08:20 -0400
Received: by mail-oa0-f48.google.com with SMTP id o17so1417634oag.21
        for <netdev@vger.kernel.org>; Tue, 06 Aug 2013 11:08:19 -0700 (PDT)
In-Reply-To: <5200A8BC.4010402@linux.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 06, 2013 at 10:41:48AM +0300, Eliezer Tamir wrote:
> On 06/08/2013 00:22, Shawn Bohrer wrote:
> > 3) I don't know if this was intentional, an oversight, or simply a
> > missing feature but UDP multicast currently is not supported.  In
> > order to add support I believe you would need to call
> > sk_mark_napi_id() in __udp4_lib_mcast_deliver().  Assuming there isn't
> > some intentional reason this wasn't done I'd be happy to test this and
> > send a patch.
> 
> This is still WIP, so our goal was to make it easy to extend for new
> cases and protocols.
> 
> For multicast, it is possible that incoming packets to come from more
> than one port (and therefore more than one queue).
> I'm not sure how we could handle that, but what we have today won't do
> well for that use-case.
 
It is unclear to me exactly what happens in this case.  With my simple
patch I'm assuming it will spin on the receive queue that received the
last packet for that socket.  What happens when a packet arrives on a
different receive queue than the one we were spinning on? I assume it
is still delivered but perhaps the spinning process won't get it until
the spinning time expires?  I'm just guessing and haven't attempted to
figure it out from looking through the code.

I put together a small test case with two senders and a single
receiver, and visually (by watching /proc/interrups) verified that
their traffic went to two different queues.  The receiver received all
of the packets with busy_read enabled so it appears that it at least
superficially works.  I did not verify the effect on latency.

> What do you use for testing?

In fio 2.1.2 [1] I added support for UDP multicast.  It's not quite as
flexible as I would like but you can still test a number of scenarios
like the one above or do a basic pingpong test.

Here are my fio job files for a pingpong test:

$ cat mcudp_rr_receive
[global]
ioengine=net
protocol=udp
bs=64
size=100m
# IP address of interface to receive packets
#interface=10.8.16.21
rw=read

[pingpong]
pingpong=1
port=10000
hostname=239.0.0.0

$ cat mcudp_rr_send
[global]
ioengine=net
protocol=udp
bs=64
size=100m
# IP address of interface to send packets
#interface=10.8.16.22
rw=write

[pingpong]
pingpong=1
port=10000
hostname=239.0.0.0

Just start the receiver on one host then start the sender on a second
host:

[host1] $ fio mcudp_rr_receive

[host2] $ fio mcudp_rr_send

[1] http://brick.kernel.dk/snaps/fio-2.1.2.tar.bz2

--
Shawn

-- 

---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.

From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v3 3/3] net: sctp: Add support for MSG_MORE on
 SCTP
Date: Tue, 22 Jul 2014 15:22:21 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1727B3E7@AcuExch.aculab.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1727AF02@AcuExch.aculab.com>
 <53CE65B5.3090903@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1727B2A0@AcuExch.aculab.com>
 <53CE7B2A.90104@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>
To: 'Vlad Yasevich' <vyasevich@gmail.com>,
	"Linux Networking Development Mailing List" <netdev@vger.kernel.org>,
	"'linux-sctp@vger.kernel.org'" <linux-sctp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:45820 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752788AbaGVPXl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 11:23:41 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 25522-01 for <netdev@vger.kernel.org>;
 Tue, 22 Jul 2014 16:23:32 +0100 (BST)
In-Reply-To: <53CE7B2A.90104@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

...
> > All this is really defining the behaviour for 'broken' apps.
> > It wouldn't be completely unreasonable if a single message sent with 'MSG_MORE'
> > never actually got sent.
> 
> Actually, this code opens up a way to eat kernel memory.  Consider an application
> that does:
>    while (1) {
>        socket(IPPROTO_SCTP);
>        connect()
>        sendmsg(MSG_MORE); <- write 1 byte
>        close();
>    }
> 
> Because we send with MSG_MORE, the 1 byte gets queued to the association.  The close()
> causes us to enter SHUTDOWN_PENDING state and we never flush the buffer and close
> the association.
> 
> This is a malicious example.  Similarly, a broken application could just forget to
> clear MSG_MORE and when we end up in a condition where the amount of queued data is
> smaller then MTU and all inflight data has been acked, we'd once again be stuck.

>From a system point of view that one doesn't really matter.

> Just because application isn't doing the right thing, we can't assume it's broken.  It
> could be malicious.  We need to make this behavior robust.

Hmmm....
The amount of data per-socket is limited by the mtu and socket buffer size,
so a malicious app would have to create a lot of sockets to use a significant
amount of kernel memory.

If close() blocks forever, isn't there a worse problem with a remote app
that causes the window to be zero - and so data can't be sent and the
close will block forever anyway?
I've never liked protocols that wait forever for send data to drain on disconnect.
Seems like an 'accident' waiting to happen.

I'm not sure what would be needed to be done to cause queued send data to be
sent when SCTP_F_TX_MSG_MORE is cleared by close() or set/clear SCTP_NODELAY.
It is probably a simple call to the correct function.

	David

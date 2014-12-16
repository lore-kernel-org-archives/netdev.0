From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 1/5] e1000e: reset MAC-PHY interconnect on 82577/82578
Date: Tue, 16 Dec 2014 10:48:26 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CA0D645@AcuExch.aculab.com>
References: <1418725700-31465-1-git-send-email-Yanjun.Zhu@windriver.com>
 <1418725700-31465-2-git-send-email-Yanjun.Zhu@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Zhu Yanjun <Yanjun.Zhu@windriver.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: 'Zhu Yanjun' <zyjzyj2000@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"w@1wt.eu" <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:56105 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750921AbaLPKtv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 05:49:51 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 15341-01 for <netdev@vger.kernel.org>;
 Tue, 16 Dec 2014 10:49:42 +0000 (GMT)
In-Reply-To: <1418725700-31465-2-git-send-email-Yanjun.Zhu@windriver.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun
> 2.6.x kernels require a similar logic change as commit 6dfaa76
> [e1000e: reset MAC-PHY interconnect on 82577/82578] introduces
> for newer kernels.
> 
> During Sx->S0 transitions, the interconnect between the MAC and PHY on
> 82577/82578 can remain in SMBus mode instead of transitioning to the
> PCIe-like mode required during normal operation.  Toggling the LANPHYPC
> Value bit essentially resets the interconnect forcing it to the correct
> mode.
> 
> after review of all intel drivers, found several instances where
> drivers had the incorrect pattern of:
> memory mapped write();
> delay();
> 
> which should always be:
> memory mapped write();
> write flush(); /* aka memory mapped read */
> delay();

Probably not only the intel drivers.
I'd bet that a lot of the delay() calls are wrong.
 
> explanation:
> The reason for including the flush is that writes can be held
> (posted) in PCI/PCIe bridges, but the read always has to complete
> synchronously and therefore has to flush all pending writes to a
> device.  If a write is held and followed by a delay, the delay
> means nothing because the write may not have reached hardware
> (maybe even not until the next read)

It might even be that the 'write flush' (ie a read) guarantees to
generates a long enough delay that the delay() itself isn't needed.

	David

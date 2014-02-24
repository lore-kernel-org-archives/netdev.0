From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] loopback: sctp: add NETIF_F_SCTP_CSUM to
 device features
Date: Mon, 24 Feb 2014 10:17:58 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6C96DE@AcuExch.aculab.com>
References: <1393074113-9922-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: 'Daniel Borkmann' <dborkman@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:55151 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752583AbaBXKS4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 05:18:56 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 08949-04 for <netdev@vger.kernel.org>;
 Mon, 24 Feb 2014 10:18:54 +0000 (GMT)
In-Reply-To: <1393074113-9922-1-git-send-email-dborkman@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann
> Drivers are allowed to set NETIF_F_SCTP_CSUM if they have
> hardware crc32c checksumming support for the SCTP protocol.
> Currently, NETIF_F_SCTP_CSUM flag is available in igb,
> ixgbe, i40e/i40evf drivers and for vlan devices.
> 
> If we don't have NETIF_F_SCTP_CSUM then crc32c is done
> through CPU instructions, invoked from crypto layer, or
> if not available as slow-path fallback in software.
> 
> Currently, loopback device propagates checksum offloading
> feature flags in dev->features, but is missing SCTP checksum
> offloading. Therefore, account for NETIF_F_SCTP_CSUM as
> well.
> 
> Before patch:
> 
> ./netperf_sctp -H 192.168.0.100 -t SCTP_STREAM_MANY
> SCTP 1-TO-MANY STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.0.100 () port 0 AF_INET
> Recv   Send    Send
> Socket Socket  Message  Elapsed
> Size   Size    Size     Time     Throughput
> bytes  bytes   bytes    secs.    10^6bits/sec
> 
> 4194304 4194304   4096    10.00    4683.50
> 
> After patch:
...
> 4194304 4194304   4096    10.00    15348.26

That seems a much larger increase than you'd expect from removing
a software CRC of the data chunks.
Are you sure that some other difference in the data flows wasn't
also triggered.

I'm also not sure that 4096 is a representative message size for SCTP.
I'm not sure what else it is used for, but SCTP is used to carry various
SS7 protocols and interfaces over IP (SIGTRAN: eg M3UA). For SS7 the maximum
message size is around 270 bytes, and the average size nearer 100.

It is also difficult to model, but the typical traffic for SS7 is neither
bulk data, nor command-response. Rather it is single packets (maybe received
from one of many 64k links) that need transmitting within a reasonable time
interval, a delay of 1-2ms might be acceptable.
This basically means that Nagle has to be disabled (because you never want
the 'timeout waiting for an ack') and almost every data chunk ends up in
its own (short) ethernet frame.

	David

From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: Re: [PATCH] mlx4_en: map entire pages to increase throughput
Date: Mon, 16 Jul 2012 17:57:08 -0300
Message-ID: <20120716205708.GB16137@oc1711230544.ibm.com>
References: <1342458113-10384-1-git-send-email-cascardo@linux.vnet.ibm.com>
 <50044F1D.6000703@hp.com>
 <20120716190611.GA1023@oc1711230544.ibm.com>
 <50046EB1.5040909@hp.com>
 <CAJZOPZL3F+xdHSFfhg7v9A6DDjT6CPK=kgwyzcE6c0pGYFyupg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rick Jones <rick.jones2@hp.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"yevgenyp@mellanox.co.il" <yevgenyp@mellanox.co.il>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"amirv@mellanox.com" <amirv@mellanox.com>,
	"brking@linux.vnet.ibm.com" <brking@linux.vnet.ibm.com>,
	"leitao@linux.vnet.ibm.com" <leitao@linux.vnet.ibm.com>,
	"klebers@linux.vnet.ibm.com" <klebers@linux.vnet.ibm.com>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"anton@samba.org" <anton@samba.org>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp04.br.ibm.com ([32.104.18.25]:37907 "EHLO
	e24smtp04.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751919Ab2GPU5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 16:57:19 -0400
Received: from /spool/local
	by e24smtp04.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Mon, 16 Jul 2012 17:57:16 -0300
Received: from d24relay02.br.ibm.com (d24relay02.br.ibm.com [9.13.184.26])
	by d24dlp02.br.ibm.com (Postfix) with ESMTP id 268AE1DC0051
	for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 16:57:13 -0400 (EDT)
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
	by d24relay02.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6GKuRWQ34865326
	for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 17:56:27 -0300
Received: from d24av04.br.ibm.com (loopback [127.0.0.1])
	by d24av04.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6GIv0Cg001822
	for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 15:57:01 -0300
Content-Disposition: inline
In-Reply-To: <CAJZOPZL3F+xdHSFfhg7v9A6DDjT6CPK=kgwyzcE6c0pGYFyupg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 16, 2012 at 11:43:33PM +0300, Or Gerlitz wrote:
> On Mon, Jul 16, 2012 at 10:42 PM, Rick Jones <rick.jones2@hp.com> wrote:
> 
> > I was thinking more along the lines of an additional comparison,
> > explicitly using netperf TCP_RR or something like it, not just the packets
> > per second from a bulk transfer test.
> 
> 
> TCP_STREAM from this setup before the patch would be good to know as well
> 

Hi, Or.

Does the stream test that I did with uperf using messages of 64000 bytes
fit?

TCP_NODELAY does not make a difference in this case. I get something
around 3Gbps before the patch and something around 9Gbps after the
patch.

Before the patch:

# ./uperf-1.0.3-beta/src/uperf -m tcp.xml
Starting 16 threads running profile:tcp_stream ...   0.00 seconds
Txn1          0 /1.00(s) =            0          16op/s
Txn2    20.81GB /59.26(s) =     3.02Gb/s        5914op/s
Txn3          0 /0.00(s) =            0      128295op/s
-------------------------------------------------------------------------------------------------------------------------------
Total   20.81GB /61.37(s) =     2.91Gb/s        5712op/s

Netstat statistics for this run
-------------------------------------------------------------------------------------------------------------------------------
Nic       opkts/s     ipkts/s     obits/s     ibits/s
eth6       252459       31694   3.06Gb/s  16.74Mb/s
eth0            2          18   3.87Kb/s  14.28Kb/s
-------------------------------------------------------------------------------------------------------------------------------

Run Statistics
Hostname           Time        Data   Throughput   Operations
Errors
-------------------------------------------------------------------------------------------------------------------------------
10.0.0.2         61.47s     20.81GB     2.91Gb/s       350528
0.00
master           61.37s     20.81GB     2.91Gb/s       350528
0.00
-------------------------------------------------------------------------------------------------------------------------------
Difference(%)     -0.16%      0.00%        0.16%        0.00%
0.00%


After the patch:

# ./uperf-1.0.3-beta/src/uperf -m tcp.xml
Starting 16 threads running profile:tcp_stream ...   0.00 seconds
Txn1          0 /1.00(s) =            0          16op/s
Txn2    64.50GB /60.27(s) =     9.19Gb/s       17975op/s
Txn3          0 /0.00(s) =            0
-------------------------------------------------------------------------------------------------------------------------------
Total   64.50GB /62.27(s) =     8.90Gb/s       17397op/s

Netstat statistics for this run
-------------------------------------------------------------------------------------------------------------------------------
Nic       opkts/s     ipkts/s     obits/s     ibits/s
eth6       769428       96018   9.31Gb/s  50.72Mb/s
eth0            1          15   2.48Kb/s  13.59Kb/s
-------------------------------------------------------------------------------------------------------------------------------

Run Statistics
Hostname           Time        Data   Throughput   Operations
Errors
-------------------------------------------------------------------------------------------------------------------------------
10.0.0.2         62.27s     64.36GB     8.88Gb/s      1081096
0.00
master           62.27s     64.50GB     8.90Gb/s      1083325
0.00
-------------------------------------------------------------------------------------------------------------------------------
Difference(%)     -0.00%      0.21%        0.21%        0.21%
0.00%


Profile tcp.xml:

<?xml version="1.0"?>
<profile name="TCP_STREAM">
  <group nthreads="16">
        <transaction iterations="1">
            <flowop type="connect" options="remotehost=10.0.0.2 protocol=tcp tcp_nodelay"/>
        </transaction>
        <transaction duration="60">
            <flowop type="write" options="count=160 size=64000"/>
        </transaction>
        <transaction iterations="1">
            <flowop type="disconnect" />
        </transaction>
  </group>
</profile>

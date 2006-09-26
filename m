From: Philip Craig <philipc@snapgear.com>
Subject: Re: [patch] neighbour.c, pneigh_get_next() skips published entry
Date: Tue, 26 Sep 2006 15:59:31 +1000
Message-ID: <4518C1C3.10004@snapgear.com>
References: <20060925164535.4245ee02.akpm@osdl.org> <20060925.164731.71091985.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org, jari.takkala@q9.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.snapgear.com ([203.143.235.140]:63179 "EHLO
	cyberguard.com.au") by vger.kernel.org with ESMTP id S1751543AbWIZF7f
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Sep 2006 01:59:35 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060925.164731.71091985.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
>> I've been sitting on this patch because afaik the problem which it purports
>> to fix remains unfixed.
>>
>> Should I drop it??
>>
>> Thanks.
> 
> Please drop it, the patch submitted didn't give us the feedback
> and test results we asked for which is necessary to pinpoint the
> true issue here.

It is faster to reproduce with a smaller block size.
I haven't looked in detail to find the cause, but I did notice that
neigh_seq_start() does a pos_minus_one adjustment, and neigh_seq_next()
does not.


First, with only one entry, both block sizes work:

# dd if=/proc/net/arp bs=1024
IP address       HW type     Flags       HW address            Mask     Device
10.46.1.1        0x1         0x2         00:04:23:C8:8D:E9     *        eth0
0+1 records in
0+1 records out
156 bytes (156 B) copied, 0.000161 seconds, 969 kB/s
# dd if=/proc/net/arp bs=128
IP address       HW type     Flags       HW address            Mask     Device
10.46.1.1        0x1         0x2         00:04:23:C8:8D:E9     *        eth0
1+1 records in
1+1 records out
156 bytes (156 B) copied, 0.000193 seconds, 808 kB/s


But add another entry, and it is lost with bs=128:

# arp -Ds 1.1.1.1 eth1 pub
# dd if=/proc/net/arp bs=1024
IP address       HW type     Flags       HW address            Mask     Device
10.46.1.1        0x1         0x2         00:04:23:C8:8D:E9     *        eth0
1.1.1.1          0x1         0xc         00:00:00:00:00:00     *        eth1
0+1 records in
0+1 records out
233 bytes (233 B) copied, 2.6e-05 seconds, 9.0 MB/s
# dd if=/proc/net/arp bs=128
IP address       HW type     Flags       HW address            Mask     Device
10.46.1.1        0x1         0x2         00:04:23:C8:8D:E9     *        eth0
1+1 records in
1+1 records out
156 bytes (156 B) copied, 7.9e-05 seconds, 2.0 MB/s


Add more entries, but still only one is lost:

# arp -Ds 1.1.1.2 eth1 pub
# arp -Ds 1.1.1.3 eth1 pub
# arp -Ds 1.1.1.4 eth1 pub
# arp -Ds 1.1.1.5 eth1 pub
# dd if=/proc/net/arp bs=128
IP address       HW type     Flags       HW address            Mask     Device
10.46.1.1        0x1         0x2         00:04:23:C8:8D:E9     *        eth0
1.1.1.3          0x1         0xc         00:00:00:00:00:00     *        eth1
1.1.1.2          0x1         0xc         00:00:00:00:00:00     *        eth1
1.1.1.5          0x1         0xc         00:00:00:00:00:00     *        eth1
1.1.1.4          0x1         0xc         00:00:00:00:00:00     *        eth1
3+1 records in
3+1 records out
464 bytes (464 B) copied, 3.6e-05 seconds, 12.9 MB/s

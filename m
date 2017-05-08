From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 net-next 08/10] net/ncsi: Support NCSI packet
 generation
Date: Mon, 8 May 2017 10:25:12 +1000
Message-ID: <20170508002512.GA6012@gwshan>
References: <1493786681-27468-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <1493786681-27468-9-git-send-email-gwshan@linux.vnet.ibm.com>
 <20170503125254.GF8029@lunn.ch>
 <20170504063156.GA7620@gwshan>
 <20170504120035.GQ8029@lunn.ch>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gavin Shan <gwshan@linux.vnet.ibm.com>, netdev@vger.kernel.org,
        joe@perches.com, kubakici@wp.pl, f.fainelli@gmail.com,
        davem@davemloft.net
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:58577 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750844AbdEHA0P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 7 May 2017 20:26:15 -0400
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v480NldG107843
        for <netdev@vger.kernel.org>; Sun, 7 May 2017 20:26:14 -0400
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2aa01gsy7n-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Sun, 07 May 2017 20:26:14 -0400
Received: from localhost
        by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Mon, 8 May 2017 10:26:11 +1000
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
        by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v480Q1uY2228682
        for <netdev@vger.kernel.org>; Mon, 8 May 2017 10:26:09 +1000
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
        by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v480Pap4031346
        for <netdev@vger.kernel.org>; Mon, 8 May 2017 10:25:37 +1000
Content-Disposition: inline
In-Reply-To: <20170504120035.GQ8029@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 04, 2017 at 02:00:35PM +0200, Andrew Lunn wrote:
>On Thu, May 04, 2017 at 04:31:57PM +1000, Gavin Shan wrote:
>> On Wed, May 03, 2017 at 02:52:54PM +0200, Andrew Lunn wrote:
>> >On Wed, May 03, 2017 at 02:44:39PM +1000, Gavin Shan wrote:
>> >> This introduces /sys/kernel/debug/ncsi/eth0/pkt. The debugfs entry
>> >> can accept parameters to produce NCSI command packet. The received
>> >> NCSI response packet is dumped on read. Below is an example to send
>> >> CIS command and dump its response.
>> >> 
>> >>    # echo CIS,0,0 > /sys/kernel/debug/ncsi/eth0/pkt
>> >>    # cat /sys/kernel/debug/ncsi/eth0/pkt
>> >>    NCSI response [CIS] packet received
>> >> 
>> >>    00 01 dd 80 00 0004 0000 0000
>> >
>> >Could this be done with a raw socket for Tx and
>> >libpcap/tcpdump/wireshart for Rx?
>> >
>> 
>> Andrew, it's really good question. Unfortunately, I don't think it can
>> be done solely by raw socket to transmit NCSI command packet because the
>> [packet sequence number] field in the packet can't be same to any used ones.
>> Otherwise the remote NIC will be confused and start to reponse abnormally.
>
>Just to make sure i'm on the same page. We are talking about:
>
>https://www.dmtf.org/sites/default/files/standards/documents/DSP0222_1.0.1.pdf
>
>and the sequence number is the Instance ID. This is an 8-bit number,
>and if it receives a message with the previously used IID, it should
>assume it is a re-transmit of the request and send back the old
>response. It is a very simple scheme, no windowing, only one
>outstanding command/response, just one response buffered in case of a
>re-transmit.
>
>> We could reserve some sequence number to be used by raw socket.
>
>I don't think that works. You can only have one command
>'inflight'. Packets from a raw socket would have to go through your
>state machine. Which makes it complex.
>
>libpcap should however still work. So you should probably do all the
>receive side in user space.
>

Andrew, yeah, we're on same page about the sequence number. Yes, I
agree it's going to make thing complex to transmit packet through
raw socket. So lets keep using debugfs as we had.

I need to dig how libpcap receives packets. It's appreciated if you
can give some hints about that. However, I don't see the benefit to
receive packets by libpcap, could you claim?

Cheers,
Gavin

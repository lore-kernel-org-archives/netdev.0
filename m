From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/3] l3mdev: Improve use with main table
Date: Thu, 13 Apr 2017 08:36:38 -0600
Message-ID: <e9cbd091-bb51-6f30-f31b-9080145caa93@cumulusnetworks.com>
References: <1491834122-26252-1-git-send-email-rshearma@brocade.com>
 <822ee9b5-09d6-6987-deb3-6af9d537c891@cumulusnetworks.com>
 <a7204fbc-68b5-c6f4-c76c-d33b9c85d663@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Robert Shearman <rshearma@brocade.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:34359 "EHLO
        mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752341AbdDMOgl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 10:36:41 -0400
Received: by mail-oi0-f51.google.com with SMTP id g204so67551233oib.1
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 07:36:39 -0700 (PDT)
In-Reply-To: <a7204fbc-68b5-c6f4-c76c-d33b9c85d663@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/13/17 6:48 AM, Robert Shearman wrote:
>> the patches look ok to me, but in testing them I see I refcnt problem.
>> simple reproducer:
>>
>> ip li add red type vrf table 254
>> ip link set dev eth1 vrf red
>> ip addr add 127.0.0.1/8 dev red
>> ip link set dev eth1 up
>> ip li set red up
>> ping -c1 -w1 -I red 127.0.0.1
>> ip li del red
>> --> hangs with 'uregister_netdevice: waiting for red to become free.'
> 
> Right, I've reproduced the same and it occurs even without using the
> main table and I believe it has been introduced within the last week.

The cached dst on sockets is one known place that causes a hang on a
delete. Basically the delete stalls until the sockets are closed. I have
a patch for sk_rx_dst which is the one I chased down last week.
sk_dst_cache is another possibility.

Neither of those should be at play with the above example because the
ping command runs and then exits.

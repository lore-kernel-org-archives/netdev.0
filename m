From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2] netfilter: xt_hashlimit: Fix integer divide round to
 zero.
Date: Tue, 21 Feb 2017 13:48:39 +0100
Message-ID: <20170221124839.GA3738@salvia>
References: <1486391287.2374.1.camel@gmail.com>
 <20170206225033.26231-1-alban.browaeys@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alban Browaeys <alban.browaeys@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58190 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752368AbdBUMst (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 21 Feb 2017 07:48:49 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 7DAC11872CF
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 13:48:46 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 6E295DA844
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 13:48:46 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 3A166DA81C
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 13:48:44 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20170206225033.26231-1-alban.browaeys@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 06, 2017 at 11:50:33PM +0100, Alban Browaeys wrote:
> Diving the divider by the multiplier before applying to the input.
> When this would "divide by zero", divide the multiplier by the divider
> first then multiply the input by this value.
> 
> Currently user2creds outputs zero when input value is bigger than the
> number of slices and  lower than scale.
> This as then user input is applied an integer divide operation to
> a number greater than itself (scale).
> That rounds up to zero, then we mulitply zero by the credits slice size.
>   iptables -t filter -I INPUT --protocol tcp --match hashlimit
>   --hashlimit 40/second --hashlimit-burst 20 --hashlimit-mode srcip
>   --hashlimit-name syn-flood --jump RETURN
> thus trigger the overflow detection code:
> xt_hashlimit: overflow, try lower: 25000/20
> (25000 as hashlimit avd and 20 the burst)
> Here:
> 134217 slices of (HZ * CREDITS_PER_JIFFY) size.
> 500000 is user input value
> 1000000 is XT_HASHLIMIT_SCALE_v2
> gives: 0 as user2creds output
> Setting burst to "1" typically solve the issue ...
> but setting it to "40" does too !
> 
> This is on 32bit arch calling into revision 2 of hashlimit.

Applied to nf.git, thanks.

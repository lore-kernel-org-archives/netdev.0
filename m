From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip route: Make name of protocol 0 consistent
Date: Mon, 6 Feb 2017 14:01:07 -0800
Message-ID: <20170206140107.41569a73@xeon-e3>
References: <1486056126-23900-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:35069 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751813AbdBFWBP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 17:01:15 -0500
Received: by mail-pg0-f49.google.com with SMTP id 194so31867278pgd.2
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 14:01:15 -0800 (PST)
In-Reply-To: <1486056126-23900-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  2 Feb 2017 09:22:06 -0800
David Ahern <dsa@cumulusnetworks.com> wrote:

> iproute2 can inconsistently show the name of protocol 0 if a route with
> a custom protocol is added. For example:
>   dsa@cartman:~$ ip -6 ro ls table all | egrep 'proto none|proto unspec'
>   local ::1 dev lo  table local  proto none  metric 0  pref medium
>   local fe80::225:90ff:fecb:1c18 dev lo  table local  proto none  metric 0  pref medium
>   local fe80::92e2:baff:fe5c:da5d dev lo  table local  proto none  metric 0  pref medium
> 
> protocol 0 is pretty printed as "none". Add a route with a custom protocol:
>   dsa@cartman:~$ sudo ip -6 ro add  2001:db8:200::1/128 dev eth0 proto 123
> 
> And now display has switched from "none" to "unspec":
>   dsa@cartman:~$ ip -6 ro ls table all | egrep 'proto none|proto unspec'
>   local ::1 dev lo  table local  proto unspec  metric 0  pref medium
>   local fe80::225:90ff:fecb:1c18 dev lo  table local  proto unspec  metric 0  pref medium
>   local fe80::92e2:baff:fe5c:da5d dev lo  table local  proto unspec  metric 0  pref medium
> 
> The rt_protos file has the id to name mapping as "unspec" while
> rtnl_rtprot_tab[0] has "none". The presence of a custom protocol id
> triggers reading the rt_protos file and overwriting the string in
> rtnl_rtprot_tab. All of this is logic from 2004 and earlier.
> 
> The simplest change to achieve consistency is to update the rt_protos
> file to use "none" instead of "unspec".
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>  etc/iproute2/rt_protos | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/etc/iproute2/rt_protos b/etc/iproute2/rt_protos
> index 82cf9c46cf6f..21af85b9d7e1 100644
> --- a/etc/iproute2/rt_protos
> +++ b/etc/iproute2/rt_protos
> @@ -1,7 +1,7 @@
>  #
>  # Reserved protocols.
>  #
> -0	unspec
> +0	none
>  1	redirect
>  2	kernel
>  3	boot

This doesn't look like a good solution, you loose the value of unspec.

Just to clarify. You added a custom protocol value to netlink.
And then you are using upstream iproute2 source to display the value.

The correct behavior in that case would be for upstream ip route show command to display
a numeric value (rather than a symbolic name).

But if you are shipping your own version of iproute then add an additional entry
to rt_protos with your new name, and for sanity update the local copy of rtnetlink.h

Of course, submitting your custom protocol upstream is the best long term solution.

From: "Philip A. Prindeville" <philipp_subx@redfish-solutions.com>
Subject: Re: Network QoS support in applications
Date: Thu, 11 Mar 2010 11:56:19 -0700
Message-ID: <4B993CD3.4020406@redfish-solutions.com>
References: <87k4v5nuej.fsf@purkki.valot.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: Kalle Valo <kalle.valo@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:60610 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934161Ab0CKTC2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 14:02:28 -0500
In-Reply-To: <87k4v5nuej.fsf@purkki.valot.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for jumping in this late, after all, I did start this by stirring
up the whole issue... hate to be "hit and run".  ;-)

I'll try to catch up on the thread today, but here are a couple of
thoughts while I'm doing that.


On 01/26/2010 01:27 AM, Kalle Valo wrote:
> Hello,
>
> I have been trying to understand how applications should use network
> QoS. My interest have been mostly from wireless perspective,
> especially how to utilise WMM and U-APSD properly, but naturally this
> applicable to all networks.
>
> I have done some research about this, but I haven't managed to get
> anywhere. For example, from my point of view DiffServ is just one big
> mess and I can't see how in practise it can help applications.
>
> I wrote a small wiki page to sum up my findings:
>
> http://wireless.kernel.org/en/developers/Documentation/qos
>
> I would like to clear up all this by and I'm willing to write a
> document for application developers about network QoS. But I need help
> to understand what's the proper way to mark different QoS
> prioritities.
>   

I would argue that application developers don't need to (and indeed
shouldn't) code QoS values into their programs.  QoS is a policy issue,
not a protocol one.

What I mean is that they should leave the configuration mechanism to
mark traffic, but let the site administrator (or more often, the site
network manager) decide on (and set) the QoS values to be used.

I've been working on this...  in most cases, the OSS package owners said
"put in the hooks", and have the default continue to do what's always
been done (even if (a) that means using TOS values [as opposed to QOS
values] that are obsolete, and (b) in some cases, the value of those
settings [i.e. IPTOS_LOWCOST] now conflict in a destructive way with new
meanings [that is ECN congestion settings])... and that's what has
typically been done.

There are, of course, no widely accepted standards for what mapping goes
with what application.  Some sites might consider video
mission-critical, others might consider it a bandwidth hog and a
nuisance that interferes with their transactional ODBC.

There is no one-size-fits-all.

So, going with the notional that the applications should be QoS-capable
but not out-of-the-box QoS-enabled, I've written the following patches:

https://support.ntp.org/bugs/show_bug.cgi?id=752

https://issues.apache.org/bugzilla/show_bug.cgi?id=42848

https://issues.apache.org/bugzilla/show_bug.cgi?id=48361

https://bugzilla.andrew.cmu.edu/show_bug.cgi?id=3184

http://proftp.cvs.sourceforge.net/viewvc/proftp/proftpd/contrib/mod_qos.c?view=log

ftp://ftp.redfish-solutions.com/pub/sendmail-8.14-qos.patch

https://bugzilla.mindrot.org/show_bug.cgi?id=1733


And I'm currently working on patches for Firefox and Thunderbird.

In the examples for the sample configuration files, when appropriate, I use the DSCP tagging values recommended in:

http://www.cisco.com/en/US/docs/solutions/Enterprise/WAN_and_MAN/QoS_SRND_40/QoSCampus_40.html#wp1098122




> In the wiki page I have tried to come up with different possible
> solutions (copied below), but I'm sure there are even more ways.
>
> Please comment. I would like to get some understanding about this.
>
>
> ----------------------------------------------------------------------
> Solution 1: SO_PRIORITY with values 0-7
>
> Easy, applications need to just use setsockopt() and be done with it.
> It's unknown how widely supported values 0-7 are and the exact meaning
> of them, but at least they make sense (0 default, 1 lowest priority
> and 7 highest priority). The problem is that the priority is used only
> in the first link, rest of the route is not able to benefit from the
> classification.
>
> Pros:
>
>     * easy for applications
>     * works with both IPv4 and IPv6 
>
> Cons:
>
>     * only visible in in the first L2 link, not visible to upper
>       layers (IP)
>     * no well defined meaning for the priority values 
>
> Solution 2: SO_PRIORITY with values 256-263
>
> mac80211 uses these values to map the packets to DSCP classes. Most
> probably non other stack or driver (even non-wifi ones) use these
> values. Otherwise similar as Solution 1.
>
> Pros:
>
>     * easy for applications
>     * works with both IPv4 and IPv6 
>
> Cons:
>
>     * only visible in in the first L2 link, not visible to upper
>       layers (IP)
>     * no well defined meaning for the priority values
>     * using values over 256 is not intuitive 
>
> Solution 3: IPv4 DSCP field with values 0-7
>
> Most, if not all, wifi drivers should use it. And, in theory, the
> receiver should also benefit from the classification, unless ISPs
> modify it of course. But the standardisation for IPv4 QoS bits is a
> mess.
>
> Pros:
>
>     * visible in IP layer (but ISPs change the value often?) 
>
> Cons:
>
>     * applications need to handle IPv4 and IPv6 separately 
> ----------------------------------------------------------------------
>
>   

Solution 3': IPv4 with 1:1 mapping of Class-Selectors/Precedence to 802.1p

First, a lot of people hear "DSCP" and they freak out because it's
'complicated'.  Well, that's debatable, but let's not go there.

802.1p and Class-Selectors (i.e. the old RFC-791 meaning of
'precedence') are both fairly straightforward.  So let's go with that.

How about having a 1:1 mapping array that can be administrator specified
that maps class selectors (CS0-7) onto 802.1p precedence values?  We
could use sysctl -w to modify this locally.






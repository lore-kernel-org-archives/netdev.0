From: Michael Stone <michael@laptop.org>
Subject: Re: RFC: Network privilege separation.
Date: Wed, 7 Jan 2009 21:31:11 -0500
Message-ID: <20090108023111.GJ3164@didacte.laptop.org>
References: <1231307334-9542-1-git-send-email-michael@laptop.org> <87mye2yg8a.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.laptop.org ([18.85.2.145]:32788 "EHLO mail.laptop.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751326AbZAHCbM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 21:31:12 -0500
Received: from didacte.laptop.org (dhcp-47-72.media.mit.edu [18.85.47.72])
	by mail.laptop.org (Postfix) with SMTP id 8128023B41
	for <netdev@vger.kernel.org>; Wed,  7 Jan 2009 21:31:13 -0500 (EST)
Content-Disposition: inline
In-Reply-To: <87mye2yg8a.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 07, 2009 at 10:10:45PM +0100, Andi Kleen wrote:
>Michael Stone <michael@laptop.org> writes:
>
>> For the sake of discussion, I have written up and documented one possible
>> implementation of this concept based on the idea of a new rlimit named
>> RLIMIT_NETWORK in the following patch series. 
>>
>> I eagerly await your questions, comments, suggestions, and improvements.
>
>At least for outgoing packets you could already do it using the netfilter
>owner match and a suitable uid. I suppose that could be also extended
>for incoming packets.

While it's certainly true that you can simulate /some/ of the functionality of
my patch with the (deprecated?) netfilter owner match extension and by
synthesizing new uids as needed, I'm fairly sure that you'll run into some
serious complications involving concurrent manipulations of shared mutable
state which my proposal does not suffer from.

For example:

   * in order to user owner-match, you need to specify a uid and you probably
     need to back it up with an account in the pwd database in order to keep
     random bits of userland happy. What uid should you use?

     -- if it's the same as Joe User's uid, then you're probably going to break
        random other parts of Joe User's software stack. How is Joe going to
        debug this?

         + (unless, of course, you've also got CAP_NET_ADMIN, use the new net
           namespaces work, /and/ reconfigure your whole networking stack inside
           the new NS.)
    
     -- if it's different from Joe User's regular uid, then where did it come
        from and how is Joe going to clean it up when he no longer needs it?

         + again, privilege is required, either in the form of a setuid
           executable, CAP_SETUID capability, or an NSS module (or some
           combination of these)

   * so far as I know, netfilter is only commonly used to filter IP traffic. Can
     I really use it to limit connections to abstract unix sockets?

   * I think there are some problems with resource acquisition, trust, and
     finalization:

     -- something has to work out the actual firewall rules which need to be
        added. 

         + why should you or your sysadmin trust whatever is doing this to pick
           the right ones?

     -- something (with privilege) needs to install the firewall rules and needs
        to remove unneeded rules or you've got a space leak.

         + are there any significant race conditions between whatever is
           installing the rules and whatever is removing the dead rules?

Conclusion: so far as I can see, RLIMIT_NETWORK is, in every way, a smaller
expansion of the end user's trusted code base and should therefore be preferred
in comparison netfilter-based solutions for process-level network privilege
separation tasks. Do you see things differently?

Thanks very much,

Michael

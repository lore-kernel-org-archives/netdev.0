From: =?UTF-8?B?RGF2aWQgVMOkaHQ=?= <dave.taht@gmail.com>
Subject: Re: [PATCH] net: add sysctl allow_so_priority for SO_PRIORITY setsockopt
Date: Sat, 22 Oct 2011 11:01:18 +0200
Message-ID: <4EA2865E.2050305@gmail.com>
References: <1319235725-3046-1-git-send-email-zenczykowski@gmail.com> <20111022.000406.350185785547409199.davem@davemloft.net> <CAHo-OoxtAmzPjr4R7jQOk9GGQo7i-qVmoaY8vTYDQDj1HXsPNA@mail.gmail.com> <20111022.025836.1306779710775525629.davem@davemloft.net> <CAHo-OoyVSbsxb8U3Y5WCNRsxjr00g1O3HJcT1fmu5cmP5i-JsA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010207080509020400080605"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: =?UTF-8?B?TWFjaWVqIMW7ZW5jenlrb3dza2k=?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37990 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753414Ab1JVJBX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Oct 2011 05:01:23 -0400
Received: by wyg36 with SMTP id 36so4691033wyg.19
        for <netdev@vger.kernel.org>; Sat, 22 Oct 2011 02:01:22 -0700 (PDT)
In-Reply-To: <CAHo-OoyVSbsxb8U3Y5WCNRsxjr00g1O3HJcT1fmu5cmP5i-JsA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010207080509020400080605
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

On 10/22/2011 10:27 AM, Maciej Żenczykowski wrote:
>> I also don't see why we'd want to allow disabling this either.

I have been watching this and the other capability patches go by with 
interest. My use case is that I would like to be running "named" as a 
non-root user, but would like it to vary the dscp (tos) field on a per 
connection basis.

tcp zone transfers = bulk
tcp/udp queries = something like interactive | CS5 (this moves dns 
queries into the VI queue on wireless - which can also be done with 
SO_PRIORITY)

Having TOS modification as a grant-able capability and otherwise 
restricting it makes some sense in a world of otherwise unrestricted 
user programs in the clouds, however I note that setting CS1, reducing 
something from best effort to background, should also be allowed 
universally.

I note that another way to hammer down someone elses (guest machine, 
external router, etc) TOS settings would be to do it in iptables, but to 
do it on a fine grained basis at present would take up to 63 iptables 
rules...

lastly...

The skb->priority field needs some re-thought. In the case of wireless, 
it selects a different tx queue based on magic (see net/wireless/utils.c)

         /* skb->priority values from 256->263 are magic values to
          * directly indicate a specific 802.1d priority.  This is used
          * to allow 802.1d priority to be passed directly in from VLAN
          * tags, etc.
          */
         if (skb->priority >= 256 && skb->priority <= 263)
                 return skb->priority - 256;


classification is an aristotelian rathole!

>> I really hate these patches that offer ways to disable things
>> that normally work, and thus break apps when the non-default
>> is selected.
> Well... the purpose of settings like this is precisely to break functionality
> when the default is not set ;-)
>
>> I kind of have a feeling the kind of situation you're trying to
>> account for, you have some cloud where people run random stuff
>> that you don't control.
> Yes, I have control of the kernel, I have control of root, I have control of
> some daemons that are running on the machine, but I don't really have
> control of the entirety of userspace, some of it I have source code for
> and could audit to guarantee correctness (but I can't really enforce
> that on the users, ultimately they can run any binary),
> and for some of it I don't even have that.  Either way, it's much
> easier to delegate setting policy to
> userspace management daemon(s), and leave enforcing it to the kernel.
> This is just one more such knob.
>
>> But you didn't specify this, and we just have to guess.  Why don't you
>> describe the specific situation where you want to modify this setting?
>> Please do this instead of just talking about what the side effects are
>> inside of the kernel.  That's much less interesting when it comes to
>> patches like this.
> Very well, that's a good point.
>
> Here's an attempt to provide some insight.
>
> I am attempting to allow not-fully-code-audited nor fully trusted apps to run
> in a cgroup containerized environment, with many apps in many
> containers (not 1:1, has hierarchies) on a single kernel.
> The apps are in the believed to not be actively malicious class, but
> very likely to be buggy, or written by ill-advised programmers based
> on wrong/outdated or otherwise incorrect documentation.  I cannot rely
> on unprivileged userspace getting things right.
> I have to have some mechanism to grant these apps permissions to
> utilize specific levels of network fabric priority.  For this I have
> the aforementioned per-cgroup allowed TOS settings.  VLANs are not appropriate
> because a client with high priority net privs is allowed to send a
> request to a server with no special priority permissions.
> (there are further patches to support tcp tos reflection so the server
> can automatically respond with the client's priority)
>
> Multiqueue networking combined with hardware priority queues and xps
> desires to use skb->priority + active cpu for tx queue selection.
> In this particular case TX queue selection should happen based on the
> TOS priority.
> Setting TOS automatically sets sk_priority (and hence skb->priority).
> So all's good, so long as userspace doesn't go and change the
> sk_priority field via SO_PRIORITY and break the mapping.
>
> As a further note:
>
> Some of these apps may be a little more special, a little more
> audited, and a little more trusted.
> Enough so that they might be granted CAP_NET_RAW, but not enough so
> that they can get CAP_NET_ADMIN.
> Hence the general desire for CAP_NET_ADMIN to control general
> machine-global networking state, but not have it control
> per-socket or per-packet settings.  ie. bringing up or down an
> interface affects everyone (hence must be CAP_NET_ADMIN, and much more
> tightly controlled), while spoofing a packet doesn't really negatively
> affect anyone (you can't assume the network is trusted, so there can
> be
> external sources of spoofing or eavesdropping anyway).
>
> ---
>
> I could attempt to publish the vast majority of our internal
> networking code base (there isn't really anything secret in there),
> but it's based on 2.6.34 and even after two years of attempting to
> clean it up and refactor it (along with a rebase from 2.6.26, and all
> while actively continuing development) I'm still not at the point were
> I would consider this to be a particular useful course of action
> (there's a lot of bugfixes of bugfixes of crappy patches in there,
> plus hacks, plus tons of backports from upstream, and tons of code
> which is upstream but slightly differently then we have it internally,
> because we had it first, and pushed v2 upstream, etc...).  Instead I'm
> trying to get the easy hanging fruit out of the way, rebase our
> patches onto probably 3.2 or 3.3, likely sending some more your way
> during the process, and see where that leaves us.  Basically trying to
> reduce the delta.  We will always have internal only patches, but the
> fewer, the less burden for us, hence I'm trying to get the ones I
> believe to be potentially useful externally upstreamed.  Obviously
> whatever patches you don't accept, we'll still keep around locally.
>
> Maciej
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Dave Täht


--------------010207080509020400080605
Content-Type: text/x-vcard; charset=utf-8;
 name="dave_taht.vcf"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="dave_taht.vcf"

YmVnaW46dmNhcmQNCmZuO3F1b3RlZC1wcmludGFibGU6RGF2ZSBUPUMzPUE0aHQNCm47cXVv
dGVkLXByaW50YWJsZTpUPUMzPUE0aHQ7RGF2ZQ0KZW1haWw7aW50ZXJuZXQ6ZGF2ZS50YWh0
QGdtYWlsLmNvbQ0KdGVsO2hvbWU6MS0yMzktODI5LTU2MDgNCnRlbDtjZWxsOjA2Mzg2NDUz
NzQNCngtbW96aWxsYS1odG1sOkZBTFNFDQp2ZXJzaW9uOjIuMQ0KZW5kOnZjYXJkDQoNCg==
--------------010207080509020400080605--

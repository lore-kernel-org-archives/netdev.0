From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC] Kernel unaligned access at __skb_flow_dissect
Date: Fri, 29 Jan 2016 13:33:05 -0800
Message-ID: <CALx6S365Vd75pQQqHNHZX5iUJVNTTyr6=npn81BVYr65t-VUDQ@mail.gmail.com>
References: <20160129180651.GA17127@oracle.com>
	<1454092428.7627.52.camel@edumazet-glaptop2.roam.corp.google.com>
	<1454093642.7627.57.camel@edumazet-glaptop2.roam.corp.google.com>
	<CALx6S34+od6o69rHQzotJFXf7kziEuQUj=xH5VUWw+YpH4FjNg@mail.gmail.com>
	<20160129210900.GD17127@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>, mwdalton@google.com,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:37592 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756987AbcA2VdG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 16:33:06 -0500
Received: by mail-ig0-f169.google.com with SMTP id h5so42177506igh.0
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2016 13:33:06 -0800 (PST)
In-Reply-To: <20160129210900.GD17127@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 29, 2016 at 1:09 PM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (01/29/16 13:00), Tom Herbert wrote:
>> Doesn't every IP/VXLAN packet contains unaligned headers? Why don't
>> those create alignment issues (like when stack looks at addresses)?
>
> They do.
>
> http://comments.gmane.org/gmane.linux.network/370672
>
> some of it was fixed in https://lkml.org/lkml/2015/7/20/63.
> There's still some NET_IP_ALIGN missing. IIRC, I was seeing
> this for mldv3, but the fix has to be done carefully, by
> someone who knows how to fully regression test it.
>
> I dont know if other tunneling methods manage to get the
> NET_IP_ALIGN correct in every case.
>
Fortunately, most encapsulations are based on 4-byte alignment.
ETHER_IP even specifies a two byte header to ensure that whatever
follows the encapsulated Ethernet header is 4-byte aligned. The
encapsulation protocols that carry Ethernet without any inserted bytes
for alignment are the potential problem (GRE, VXLAN, etc.).
NET_IP_ALIGN can't help because the outer and inner (IP) headers have
different alignment, so no one value can work.

> Also, while sparc complains about unaligned access
> in most cases, some sins may pass under the radar, and other
> platforms dont even generate traps, so it's easy to not know
> that there's a problem, a lot of the time.
>
That is worrisome. The only way I can think of to be completely
protected would be to copy encapsulated Ethernet frames to
NET_IP_ALIGN buffer in the driver :-( It doesn't look like VXLAN does
anything like that.

Tom

> --Sowmini
>

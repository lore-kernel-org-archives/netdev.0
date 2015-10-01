From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH RFC 3/7] netfilter: add NF_INET_LOCAL_SOCKET_IN chain type
Date: Thu, 1 Oct 2015 14:13:23 -0300
Message-ID: <20151001171323.GA4890@localhost.localdomain>
References: <1443525140-13493-1-git-send-email-daniel@zonque.org>
 <1443525140-13493-4-git-send-email-daniel@zonque.org>
 <20150929211959.GF19923@breakpoint.cc>
 <560B8E25.7050801@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, pablo@netfilter.org,
	daniel@iogearbox.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, balazs.scheidler@balabit.com
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41959 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753254AbbJARN2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2015 13:13:28 -0400
Content-Disposition: inline
In-Reply-To: <560B8E25.7050801@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 30, 2015 at 09:24:21AM +0200, Daniel Mack wrote:
> On 09/29/2015 11:19 PM, Florian Westphal wrote:
> > Daniel Mack <daniel@zonque.org> wrote:
> >> Add a new chain type NF_INET_LOCAL_SOCKET_IN which is ran after the
> >> input demux is complete and the final destination socket (if any)
> >> has been determined.
> >>
> >> This helps filtering packets based on information stored in the
> >> destination socket, such as cgroup controller supplied net class IDs.
> > 
> > This still seems like the 'x y' problem ("want to do X, think Y is
> > correct solution; ask about Y, but thats a strange thing to do").
> > 
> > There is nothing that this offers over INPUT *except* that sk is
> > available.  But there is zero benefit as far as I am concerned --
> > why would you want to do any meaningful filtering based on the sk at
> > that point...?
> 
> Well, INPUT and SOCKET_INPUT are just two different tools that help
> solve different classes of problems. INPUT is for filtering all local
> traffic while SOCKET_INPUT is just for such that actually has a
> listener, and they both make sense in different scenarios.

How is it better than -m socket ? It's used with tproxy, but not only,
and works quite well, thought it only supports TCP and UDP.

Something like
  iptables -N INPUT_SOCKET
  iptables -I INPUT -m socket -j INPUT_SOCKET
would achieve similar results, if I got you right.

-m socket implies in a double-lookup for the socket, yes, but that
sounds a reasonable price to pay for this while not inserting another
hook. I know of deployments using -m socket for tproxy and handling very
high rates, performance has not been a problem..

> > Drop?  Makes no sense, else application would not be running in the first
> > place.
> 
> Of course you can drop certain packets at this point, depending on other
> details. Say, for instance, you want to match all packets that are
> received by a certain task and that are originated from IP addresses of
> a specific subnet, and drop the rest. Rather than adding matches to your
> global firewall configuration for all the ports that tasks may or may
> not listen on, you can just do it on a higher level, from the
> perspective of an administrator. If you decide to let your web server
> listen on another port as well, no firewall rule configuration change is
> needed at all.
> 
> Another use case is accounting. If you want to know how much traffic a
> certain service or application in your system has caused, you don't want
> to match all its ports to firewall rules just in order to get that
> information. Instead, you can now derive that information on a
> per-application base. With this patch set, this even works just fine for
> multicast listeners, which is something that is currently impossible to
> achieve otherwise.

Sounds like you want a boosted socket match, perhaps borrowing some of
the features from owner match.

  Marcelo

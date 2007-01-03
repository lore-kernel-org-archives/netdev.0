From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH/RFC 00/10] Transparent proxying patches version 4
Date: Wed, 3 Jan 2007 20:23:01 +0300
Message-ID: <20070103172301.GA27191@2ka.mipt.ru>
References: <20070103163357.14635.37754.stgit@nienna.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netfilter-devel@lists.netfilter.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:42025 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750972AbXACRXW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jan 2007 12:23:22 -0500
To: KOVACS Krisztian <hidden@balabit.hu>
Content-Disposition: inline
In-Reply-To: <20070103163357.14635.37754.stgit@nienna.balabit>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 03, 2007 at 05:33:57PM +0100, KOVACS Krisztian (hidden@balabit.hu) wrote:
> The following set of patches implement transparent proxying support
> loosely modeled on the Linux 2.2 transparent proxying functionality.
> 
> In the last few years we've been maintaining a set of patches
> implementing Netfilter NAT to provide similar functionality. However,
> as time passed, more and more bugs surfaced, some of which were not
> possible to fix using that approach. Also, those patches required
> modification of user-space application code and the "API" provided was
> neither clean nor easy to use.
> 
> So instead of using NAT to dynamically redirect traffic to local
> addresses, we now rely on "native" non-locally-bound sockets and do
> early socket lookups for inbound IPv4 packets. These lookups are done
> in a separate Netfilter/iptables module, so there are only negligible
> performance implications of building transparent proxying support as a
> module and then not loading it.

Out of curiosity, would you use netchannels [1] if the implementation
will be much broader? Since what you have created works exactly like
netchannels netfilter NAT target (although it does not change ports, but
it can be trivially extended), but without all existing netfilter
overhead and without hacks in core TCP/UDP/IP/route code.

Some quote for netfilter maillist on behalf of advertisement :)

Network channel is peer-to-peer protocol agnostic communication channel
between hardware and userspace. They allow to work directly with
network hardware from userspace without any kind of filtering or
processing from kernel.

Network channels are organized into single multidimensional trie, which
allows to perform route, netfilter and other types of lookups in one
traversal, since it is completely protocol agnostic.

Layering model does not exist in netchannels - layers are the way to 
design protocols, not implement them, thus actual protocol processing
happens on the ends of netchannel - for example in userspace (userspace
network stack), which improves cache locality and reduce overhead of
unneded layer crossing.

Netchannels featureset includes:
* multidimensional wildcards support
* RCU searching
* single multidimensional trie for different kinds of dataflows
* dedicated processing threads with possibility to
  schedule processing on different CPUs for those
  netchannel types which are not acked with processing context
* userspace netchannel backend (allows to receive
  packets to userspace), which can be used for:
	o high-performance sniffers
	o tun/tap device replacement
	o packet socket replacement (note, that netchannels steal
	  packets from main stack)
	o userspace network stack implementation [2]
	o own protocol stack implementaion (from VPN tunnels to TOE)
* netfilter netchannel backend (only NAT is supported as the most interesting
  user, NAT caches appropriate route, so essentially routing becomes part
  of the netchannel trie)

1. Netchannels homepage.
http://tservice.net.ru/~s0mbre/old/?section=projects&item=netchannel

2. Userspace network stack.
http://tservice.net.ru/~s0mbre/old/?section=projects&item=unetstack

3. Netchannel vs. socket benchmarks.
http://tservice.net.ru/~s0mbre/blog/2006/10/26#2006_10_26
http://tservice.net.ru/~s0mbre/blog/2006/12/21#2006_12_21

4. Netchannels multidimensional wildcard trie testing.
 userspace test (scales to millions of end nodes)
   http://tservice.net.ru/~s0mbre/blog/2006/12/02#2006_12_02
 kernelspace test (tens of thousands of netchannels)
   http://tservice.net.ru/~s0mbre/blog/2006/12/21#2006_12_21_1

-- 
	Evgeniy Polyakov

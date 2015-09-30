From: Daniel Mack <daniel@zonque.org>
Subject: Re: [PATCH RFC 3/7] netfilter: add NF_INET_LOCAL_SOCKET_IN chain type
Date: Wed, 30 Sep 2015 09:24:21 +0200
Message-ID: <560B8E25.7050801@zonque.org>
References: <1443525140-13493-1-git-send-email-daniel@zonque.org>
 <1443525140-13493-4-git-send-email-daniel@zonque.org>
 <20150929211959.GF19923@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: pablo@netfilter.org, daniel@iogearbox.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	balazs.scheidler@balabit.com
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150929211959.GF19923@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/29/2015 11:19 PM, Florian Westphal wrote:
> Daniel Mack <daniel@zonque.org> wrote:
>> Add a new chain type NF_INET_LOCAL_SOCKET_IN which is ran after the
>> input demux is complete and the final destination socket (if any)
>> has been determined.
>>
>> This helps filtering packets based on information stored in the
>> destination socket, such as cgroup controller supplied net class IDs.
> 
> This still seems like the 'x y' problem ("want to do X, think Y is
> correct solution; ask about Y, but thats a strange thing to do").
> 
> There is nothing that this offers over INPUT *except* that sk is
> available.  But there is zero benefit as far as I am concerned --
> why would you want to do any meaningful filtering based on the sk at
> that point...?

Well, INPUT and SOCKET_INPUT are just two different tools that help
solve different classes of problems. INPUT is for filtering all local
traffic while SOCKET_INPUT is just for such that actually has a
listener, and they both make sense in different scenarios.

> Drop?  Makes no sense, else application would not be running in the first
> place.

Of course you can drop certain packets at this point, depending on other
details. Say, for instance, you want to match all packets that are
received by a certain task and that are originated from IP addresses of
a specific subnet, and drop the rest. Rather than adding matches to your
global firewall configuration for all the ports that tasks may or may
not listen on, you can just do it on a higher level, from the
perspective of an administrator. If you decide to let your web server
listen on another port as well, no firewall rule configuration change is
needed at all.

Another use case is accounting. If you want to know how much traffic a
certain service or application in your system has caused, you don't want
to match all its ports to firewall rules just in order to get that
information. Instead, you can now derive that information on a
per-application base. With this patch set, this even works just fine for
multicast listeners, which is something that is currently impossible to
achieve otherwise.

> So the only 'benefit' is that netcls id is available; but
> a) why is that even needed and

It's currently the only way of realizing application-level firewalls,
and it'd be an awesome feature if it actually worked.

> b) is such a huge sledgehammer just for net cgroup accounting
> worth it?

I really don't know if this approach is intrusive enough to make it
qualify as sledgehammer. I'd like to see some real-world benchmarks and
have proof there is a performance decrease for setups that don't use
such chains.

> Another question is what other strange things come up once we would
> open this door.

So let's discuss the possible drawbacks.

Again, the deal with this new chain type is simple: if there is no local
listener, the rules are not looked at. If you need rules that are
processed either way, put them in LOCAL_IN, as you always did.

>> listening on a specific task, the resulting error code that is sent
>> back to the remote peer can't be controlled with rules in
>> NF_INET_LOCAL_SOCKET_IN chains.
> 
> Right, and that makes this even weirder.

Well, to be more specific: you can only control the resulting error code
that is sent back to the remote peer _if_ there is a local listener. You
can do _anything_ _if_ there is a local listener. This is in line with
the above description and shouldn't cause much surprises for users.

> For deterministic ingress filtering you can only rely on what
> is contained in the packet.

Why so? For deterministic ingress filtering of traffic directed to a
local socket, you can as well rely on information associated with that
socket. And this is what application-level firewall rule sets are all about.


Daniel


From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next 4/7] openvswitch: add ipv6 'set'
	action
Date: Wed, 12 Dec 2012 11:17:59 -0800
Message-ID: <CAEP_g=-oe1EkyfhW9phpBTgvHj6Sqi7HQGvEmeCdyHHyWRop4g@mail.gmail.com>
References: <1354214149-33651-1-git-send-email-jesse@nicira.com>
	<1354214149-33651-5-git-send-email-jesse@nicira.com>
	<CA+mtBx-Zf9FNf11H9RM12etHnJ1bPpM_Eyc4mR7E6xsb7sUP2Q@mail.gmail.com>
	<CAEP_g=-1aWGsjR55AaD6sLLt4QzbYgUs-3hfNNONrrf8MDwSyA@mail.gmail.com>
	<CA+mtBx-84PQoHmauNpN4vYLWXcJdESMMep849DQcUAjkmC7PXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Mike Waychison <mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
To: Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CA+mtBx-84PQoHmauNpN4vYLWXcJdESMMep849DQcUAjkmC7PXQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 12, 2012 at 10:38 AM, Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
>> At an implementation level, the goal is definitely to share as much
>> code as possible.  Some of that was obviously done to support this
>> patch and I'm sure there are more areas where it could be taken
>> further.
>>
>> At a more conceptual level we've explored this path a number of times
>> and it's never been attractive since it has a tendency to drag more
>> OVS code into other parts of the kernel and generally make things
>> worse for everybody.  Of course, it's hard to say without knowing what
>> you're thinking.  Do you have a specific proposal?
>
> Where is the line drawn?  Is the intent that over the next five years
> that functionality will be added ad hoc increments to make OVS have
> the same functionality as IP tables, tc, routing?  Are we going to
> have things like NAT, stateful firewalls, DDOS mechanisms implemented
> in OVS (we already have people proposing such things!).

Definitely no to all of the above. (As an aside, years ago there was
NAT functionality in a precursor to OVS.  Everybody hated it and was
very happy when it was removed, so I wouldn't worry about that type of
thing popping up in OVS any time soon.)

The design of OVS works pretty well for the types of stateless
operations that are currently implemented because those map nicely to
flows that userspace can use to program in a fairly clean and powerful
manner.  This is much less true for things like stateful rules, QoS,
DPI, etc. because you either want to look at more information than
would usually be considered a flow or have state that changes very
quickly.  In these cases, the data plane needs to take action on its
own and the interaction with userspace is more akin to configuration
than programming.

As these types of features come up, I think you will start to see more
integration with netfilter and other tools (in fact, there are several
examples of this already - OVS QoS uses tc, the ability to interact
with skb->mark was added recently, and Pravin has been doing a lot of
work to refactor and integrate with the upstream tunneling code).
There are some definite tradeoffs to doing it this way, mostly in the
area of state management, so I don't think that it's feasible to
switch wholesale over to this model.  However, if we're careful then I
think it's possible to get the best of both worlds.

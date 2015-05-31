From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net v2] switchdev: don't abort hardware ipv4 fib offload
 on failure to program fib entry in hardware
Date: Sun, 31 May 2015 00:34:35 -0700
Message-ID: <CAE4R7bBMgsD0T6ut07eE_8ePkhWgYT8aa9f8xaFVYAP2nNs13w@mail.gmail.com>
References: <555AD11E.5040709@cumulusnetworks.com>
	<20150519.123418.481170679256206928.davem@davemloft.net>
	<20150519194731.GK9559@gospo.home.greyhouse.net>
	<20150519.162845.955021778058631119.davem@davemloft.net>
	<CAE4R7bAB2+Oy92w9RpLKL5LUq7gP1mBazBK9y4ZQ4b0k8t2WhQ@mail.gmail.com>
	<20150529075003.GA11638@nanopsycho.orion>
	<CAE4R7bDSbVo7ryzHktLWtA07RswT929bhWpYwpLZUkv1eQB1tw@mail.gmail.com>
	<20150530090057.GA1929@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	john fastabend <john.fastabend@gmail.com>,
	Netdev <netdev@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f182.google.com ([209.85.216.182]:35969 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754868AbbEaHeg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 May 2015 03:34:36 -0400
Received: by qcxw10 with SMTP id w10so38928363qcx.3
        for <netdev@vger.kernel.org>; Sun, 31 May 2015 00:34:35 -0700 (PDT)
In-Reply-To: <20150530090057.GA1929@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 30, 2015 at 2:00 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Fri, May 29, 2015 at 05:39:46PM CEST, sfeldma@gmail.com wrote:
>>On Fri, May 29, 2015 at 12:50 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> Thu, May 21, 2015 at 07:46:54AM CEST, sfeldma@gmail.com wrote:
>>>>On Tue, May 19, 2015 at 1:28 PM, David Miller <davem@davemloft.net> wrote:
>>>>> From: Andy Gospodarek <gospo@cumulusnetworks.com>
>>>>> Date: Tue, 19 May 2015 15:47:32 -0400
>>>>>
>>>>>> Are you actually saying that if users complain loudly enough about
>>>>>> the current behavior (not the change Roopa has proposed) that you
>>>>>> would be open to considering a change the current behavior?
>>>>>
>>>>> I am saying that we have a contract with users not to break existing
>>>>> behavior.  Full stop.
>>>>
>>>>After rehearing David's argument, we should probably explore option d)
>>>>which is a refinement on the fib_offload_disable mechanism we have
>>>>today.  fib_offload_disable is global for all routes.  Once we hit a
>>>>HW install problem, the global flag is set and all routes fallback to
>>>>SW.  We did this because we can't allow the failed route to exist in
>>>>SW and not in HW because it could mess up LPM searches (HW could hit
>>>>on a lesser prefix even when SW has the true LPM, because HW gets
>>>>first shot at match).  The refinement on fib_offload_disable is this:
>>>>make it per-related-prefix rather than global, and on a HW install
>>>>problem, set the flag for the related-prefix and uninstall only those
>>>>routes from HW.  Related-prefix (is there a correct term for this?)
>>>>are routes to the same dst addr but with different prefix lengths.  I
>>>>haven't parsed the fib_trie structure to see how routes are organized,
>>>>but I suspect since it's optimized for lookup the related-prefix
>>>>tracking is already there and we can build on that.
>>>
>>> This looks interesting. However, I'm not sure that it is acceptable for
>>> user to experience this hw evict of "random entries". User knows what
>>> entries are essential to have in hw. With your solution, I can see no way
>>> user can actually say what should be offloaded or not. Kernel just
>>> automagically decides.
>>
>>The default eviction policy could be based on RTA_PRIORITY: evict
>>lower priority routes first.  It would be up to the device driver to
>>decide between two routes of same priority.
>>
>>To help device driver make the decision, we could have eviction policy options:
>>
>>    Priority-base (default)
>>    Prefer IPv6 over IPv4
>>    Prefer IPv4 over IPv6
>>    Prefer single path over multipath
>>    Prefer longer prefix lengths over shorter
>>    Optimize for resource utilization
>>
>>These are portable across different switches.   They're in terms a
>>user understands.  It's up to the device driver which truly
>>understands the device constraints to translates the user's eviction
>>policy choices into something that makes sense to that device.
>
> This sounds tempting... You plan to throw in some patches, or should I
> take care of that?

My L2 backlog keeps from L3 at the moment.  What would be nice is if
someone would look into the feasibility of option d) at the
swithdev/fib level and see if it's doable.  The policy/user interface
stuff can come later.  What do we need?  My thoughts:

- Remove the check for fi->fib_net->ipv4.fib_offload_disabled in
switchdev_fib_ipv4_add() and replace it with a check to see if route
is offload_disabled.  A route is offload_disabled if the set of
related routes is marked disabled.  If route is offload_disabled, just
return 0 in switchdev_fib_ipv4_add() so that route is only installed
in the kernel fib.  (It's fine now to have a route in SW but not in
HW).

- Find/invent in fib trie the structure that relates routes with the
same prefix but different prefix lengths.  So A/8 and A/16 and A/30
are related.  B/16 is not related to the other three.  Add a bool
offload_disabled to that structure to mark them offload_disabled.  We
don't want LPM broken with something like this:

   HW: A/8, A/16, B/8
   SW: A/8, A/16, A/30, B/8

Here when HW gets an A pkt, it'll match A/16 when really SW's A/30
should have won.  Now LPM is broken.

- In the driver's fib obj add handler, if it can't install the route
because the device flat out can't support the route, then return
-EOPNOTSUPP and switchdev_fib_ipv4_add() will mark the route as
offload_disabled.  Actually, switchdev_fib_ipv4_add() needs to
additionally remove related routes from device.

- In the driver's fib obj add handler, if the route can be installed,
but at the expense of evicting some other route(s) due to evict policy
(driver's choice on which route(s) get evicted), the handler returns 0
and switchdev_fib_ipv4_add() is happy.  The driver should send a
switchdev notification to the fib layer to mark the evicted route(s)
as offload disable.

- Routes marked with offload_disabled should have RTNH_F_OFFLOAD cleared.

I think I'm being sloppy with making sure once a route is removed from
the device, all the related routes are also removed from the device.
It's late; brain not working 100%.  But I think you have the gist of
it.  I don't think there is a lot of code changes here to pull this
off.

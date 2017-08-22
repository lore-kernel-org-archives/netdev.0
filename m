From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [RFC net-next v2] bridge lwtunnel, VPLS & NVGRE
Date: Tue, 22 Aug 2017 14:01:40 +0300
Message-ID: <f96d548c-7a64-ae9a-d1ea-e9fd065f9303@cumulusnetworks.com>
References: <20170821171523.951260-1-equinox@diac24.net>
	<20170821170151.5b12a392@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	bridge@lists.linux-foundation.org, amine.kherbouche@6wind.com
To: Stephen Hemminger <stephen@networkplumber.org>,
	David Lamparter <equinox@diac24.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20170821170151.5b12a392@xeon-e3>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 22/08/17 03:01, Stephen Hemminger wrote:
> On Mon, 21 Aug 2017 19:15:17 +0200
> David Lamparter <equinox@diac24.net> wrote:
> 
>> Hi all,
>>
>>
>> this is an update on the earlier "[RFC net-next] VPLS support".  Note
>> I've changed the subject lines on some of the patches to better reflect
>> what they really do (tbh the earlier subject lines were crap.)
>>
>> As previously, iproute2 / FRR patches are at:
>> - https://github.com/eqvinox/vpls-iproute2
>> - https://github.com/opensourcerouting/frr/commits/vpls
>> while this patchset is also available at:
>> - https://github.com/eqvinox/vpls-linux-kernel
>> (but please be aware that I'm amending and rebasing commits)
>>
>> The NVGRE implementation in the 3rd patch in this series is actually an
>> accident - I was just wiring up gretap as a reference;  only after I was
>> done I noticed that that sums up to NVGRE, more or less.  IMHO, it does
>> serve well to demonstrate the bridge changes are not VPLS-specific.
>>
>> To refer some notes from the first announce mail:
>>> I've tested some basic setups, the chain from LDP down into the kernel
>>> works at least in these.  FRR has some testcases around from OpenBSD
>>> VPLS support, I haven't wired that up to run against Linux / this
>>> patchset yet.  
>>
>> Same as before (API didn't change).
>>
>>> The patchset needs a lot of polishing (yes I left my TODO notes in the
>>> commit messages), for now my primary concern is overall design
>>> feedback.  Roopa has already provided a lot of input (Thanks!);  the
>>> major topic I'm expecting to get discussion on is the bridge FDB
>>> changes.  
>>
>> Got some useful input;  but still need feedback on the bridge FDB
>> changes (first 2 patches).  I don't believe it to have a significant
>> impact on existing bridge operation, and I believe a multipoint tunnel
>> driver without its own FDB (e.g. NVGRE in this set) should perform
>> better than one with its own FDB (e.g. existing VXLAN).
>>
>>> P.S.: For a little context on the bridge FDB changes - I'm hoping to
>>> find some time to extend this to the MDB to allow aggregating dst
>>> metadata and handing down a list of dst metas on TX.  This isn't
>>> specifically for VPLS but rather to give sufficient information to the
>>> 802.11 stack to allow it to optimize selecting rates (or unicasting)
>>> for multicast traffic by having the multicast subscriber list known.
>>> This is done by major commercial wifi solutions (e.g. google "dynamic
>>> multicast optimization".)  
>>
>> You can find hacks at this on:
>> https://github.com/eqvinox/vpls-linux-kernel/tree/mdb-hack
>> Please note that the patches in that branch are not at an acceptable
>> quality level, but you can see the semantic relation to 802.11.
>>
>> I would, however, like to point out that this branch has pseudo-working
>> IGMP/MLD snooping for VPLS, and it'd be 20-ish lines to add it to NVGRE
>> (I'll do that as soon as I get to it, it'll pop up on that branch too.)
>>
>> This is relevant to the discussion because it's a feature which is
>> non-obvious (to me) on how to do with the VXLAN model of having an
>> entirely separate FDB.  Meanwhile, with this architecture, the proof of
>> concept / hack is coming in at a measly cost of:
>> 8 files changed, 176 insertions(+), 15 deletions(-)
>>
>>
>> Cheers,
>>
>> -David
>>
>>
>> --- diffstat:
>> include/linux/netdevice.h      |  18 ++++++
>> include/net/dst_metadata.h     |  51 ++++++++++++++---
>> include/net/ip_tunnels.h       |   5 ++
>> include/uapi/linux/lwtunnel.h  |   8 +++
>> include/uapi/linux/neighbour.h |   2 +
>> include/uapi/linux/rtnetlink.h |   5 ++
>> net/bridge/br.c                |   2 +-
>> net/bridge/br_device.c         |   4 ++
>> net/bridge/br_fdb.c            | 119 ++++++++++++++++++++++++++++++++--------
>> net/bridge/br_input.c          |   6 +-
>> net/bridge/br_private.h        |   6 +-
>> net/core/lwtunnel.c            |   1 +
>> net/ipv4/ip_gre.c              |  40 ++++++++++++--
>> net/ipv4/ip_tunnel.c           |   1 +
>> net/ipv4/ip_tunnel_core.c      |  87 +++++++++++++++++++++++------
>> net/mpls/Kconfig               |  11 ++++
>> net/mpls/Makefile              |   1 +
>> net/mpls/af_mpls.c             | 113 ++++++++++++++++++++++++++++++++------
>> net/mpls/internal.h            |  44 +++++++++++++--
>> net/mpls/vpls.c                | 550 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>> 20 files changed, 990 insertions(+), 84 deletions(-)
> 
> I know the bridge is an easy target to extend L2 forwarding, but it is not
> the only option. Have you condidered building a new driver (like VXLAN does)
> which does the forwarding you want. Having all features in one driver
> makes for worse performance, and increased complexity.
> 

+1

As I said before, a separate implementation will be much cleaner and will not affect
the bridge in any way, paying both performance and complexity price for something that
the majority of users will not be using isn't worth it.  In addition this creates a
silent dependency between the bridge and the fdb metadata dst users, it would be much
more preferable to be able to run them separately.
If there is any code that will need to be re-used by VPLS (or anyone else) figure out a way
to factor it out.

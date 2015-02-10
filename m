From: David Ahern <dsahern@gmail.com>
Subject: Re: [RFC PATCH 00/29] net: VRF support
Date: Tue, 10 Feb 2015 13:54:05 -0700
Message-ID: <54DA6FED.5020907@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com> <20150210005344.GA6293@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, ebiederm@xmission.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:64296 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750763AbbBJUyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 15:54:07 -0500
Received: by mail-ig0-f172.google.com with SMTP id l13so26412107iga.5
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2015 12:54:07 -0800 (PST)
In-Reply-To: <20150210005344.GA6293@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/9/15 5:53 PM, Thomas Graf wrote:
> On 02/04/15 at 06:34pm, David Ahern wrote:
>> Namespaces provide excellent separation of the networking stack from=
 the
>> netdevices and up. The intent of VRFs is to provide an additional,
>> logical separation at the L3 layer within a namespace.
>
> What you ask for seems to be L3 micro segmentation inside netns. I

I would not label it 'micro' but yes a L3 separation within a L1 separa=
tion.

> would argue that we already support this through multiple routing
> tables. I would prefer improving the existing architecture to cover
> your use cases: Increase the number of supported tables, extend
> routing rules as needed, ...

I've seen that response for VRFs as well. I have not personally tried=20
it, but from what I have read it does not work well. I think Roopa=20
responded that Cumulus has spent time on that path and has hit some=20
roadblocks.

>
>> The VRF id of tasks defaults to 1 and is inherited parent to child. =
It can
>> be read via the file '/proc/<pid>/vrf' and can be changed anytime by=
 writing
>> to this file (if preferred this can be made a prctl to change the VR=
=46 id).
>> This allows services to be launched in a VRF context using ip, simil=
ar to
>> what is done for network namespaces.
>>      e.g., ip vrf exec 99 /usr/sbin/sshd
>
> I think such as classification should occur through cgroups instead
> of touching PIDs directly.

That is an interesting idea -- using cgroups for task labeling. It=20
presents a creation / deletion event for VRFs which I was trying to=20
avoid, and there will be some amount of overhead with a cgroup. I'll=20
take a look at that option when I get some time.

As for as the current proposal I am treating VRF as part of a network=20
context. Today 'ip netns' is used to run a command in a specific networ=
k=20
namespace; the proposal with the VRF layering is to add a vrf context=20
within a namespace so in keeping with how 'ip netns' works the above=20
syntax allows a user to supply both a network namespace + VRF for=20
running a command.

>
>> Network devices belong to a single VRF context which defaults to VRF=
 1.
>> They can be assigned to another VRF using IFLA_VRF attribute in link
>> messages. Similarly the VRF assignment is returned in the IFLA_VRF
>> attribute. The ip command has been modified to display the VRF id of=
 a
>> device. L2 applications like lldp are not VRF aware and still work t=
hrough
>> through all network devices within the namespace.
>
> I believe that binding net_devices to VRFs is misleading and the
> concept by itself is non-scalable. You do not want to create 10k
> net_devices for your overlay of choice just to tie them to a
> particular VRF. You want to store the VRF identifier as metadata and
> have a stateless classifier included it in the VRF decision. See the
> recent VXLAN-GBP work.

I'll take a look when I get time.

I have not seen scalability issues creating 1,000+ net_devices.=20
Certainly the 40k'ish memory per net_device is noticeable but I believe=
=20
that can be improved (e.g., a number of entries can be moved under=20
proper CONFIG_ checks). I do need to repeat the tests on newer kernels.

>
> You could either map whatever selects the VRF to the mark or support =
it
> natively in the routing rules classifier.
>
> An obvious alternative is OVS. What you describe can be implemented i=
n
> a scalable matter using OVS and mark. I understand that OVS is not fo=
r
> everybody but it gets a fundamental principle right: Scalability
> demands for programmability.
>
> I don=E2=80=99t think we should be adding a new single purpose metada=
ta field
> to arbitrary structures for every new use case that comes up. We
> should work on programmability which increases flexibility and allows
> decoupling application interest from networking details.
>
>> On RX skbs get their VRF context from the netdevice the packet is re=
ceived
>> on. For TX the VRF context for an skb is taken from the socket. The
>> intention is for L3/raw sockets to be able to set the VRF context fo=
r a
>> packet TX using cmsg (not coded in this patch set).
>
> Specyfing L3 context in cmsg seems very broken to me. We do not want
> to bind applications any closer to underlying networking infrastructu=
re.
> In fact, we should do the opposite and decouple this completely.

That suggestion is inline with what is done today for other L3=20
parameters -- TOS, TTL, and a few others.

>
>> The 'any' context applies to listen sockets only; connected sockets =
are in
>> a VRF context. Child sockets accepted by the daemon acquire the VRF =
context
>> of the network device the connection originated on.
>
> Linux considers an address local regardless of the interface the pack=
et
> was received on.  So you would accept the packet on any interface and
> then bind it to the VRF of that interface even though the route for i=
t
> might be on a different interface.
>
> This really belongs into routing rules from my perspective which take=
s
> mark and the cgroup context into account.

Expanding the current network namespace checks to a networking context=20
is a very simple and clean way of implementing VRFs versus cobbling=20
together a 'VRF like' capability using marks, multiple tables, etc (ie.=
,=20
the existing capabilities). Further, the VRF tagging of net_devices=20
seems to readily fit into the hardware offload and switchdev=20
capabilities (e.g., add a ndo operation for setting the VRF tag on a=20
device which passes it to the driver).

Big picture wise where is OCP and switchdev headed? Top-of-rack switche=
s=20
seem to be the first target, but after that? Will the kernel ever=20
support MPLS? Will the kernel attain the richer feature set of high-end=
=20
routers? If so, how does VRF support fit into the design? As I=20
understand it a scalable VRF solution is a fundamental building block.=20
Will a cobbled together solution of cgroups, marks, rules, multiple=20
tables really work versus the simplicity of an expanded network context=
?

David

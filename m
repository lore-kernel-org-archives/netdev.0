From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: Linux 3.4.92 breaks forwarding with netfilter enabled
Date: Wed, 11 Jun 2014 09:07:01 +0200
Message-ID: <53980015.5010409@suse.cz>
References: <20140610220325.GG1970@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Florian Westphal <fw@strlen.de>, stable@vger.kernel.org,
	ML netdev <netdev@vger.kernel.org>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20140610220325.GG1970@breakpoint.cc>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/11/2014 12:03 AM, Florian Westphal wrote:
> [ stable specific regression.  I wanted to CC stable@ on my reply bel=
ow
>   but I fat-fingered the address... ]
>=20
>> On Tue, Jun 10, 2014 at 12:43 PM, Egerv=E1ry Gergely <gergely@egerva=
ry.hu> wrote:
>>> Hi,
>>>
>>> we have just upgraded our systems from 3.4.91 (longterm) to 3.4.92.
>>> Since then we are experiencing dozens of MTU-related network timeou=
t
>>> issues. Reverting back to 3.4.91 fixes all of these problems.
>>>
>>> Both kernel versions are built from vanilla sources with the same
>>> .config. These can be highly reproduced over VPN tunnels or even ov=
er
>>> simple ethernet connections when using DNAT. (TCP port forward) It
>>> looks like MTU path discovery is somehow affected.
>>>
>>> ICMP is not filtered in our network. (For testing, we flushed all
>>> iptables rules, set all policies to ACCEPT, and problem still exist=
s.)
>>> We do not use any special sysctl settings. Was there any changes
>>> related to packet forwarding or MTU discovery?
>=20
> These were in earlier releases than 3.4.92.
>=20
>> some combination of old kernel and backport of ("net: ipv4:
>> ip_forward: fix inverted local_df test") ?
>> just guessing
>=20
> Excellent guess.  Yes, this is the culprit.
>=20
> Quoting that patch changelog:
>=20
> 'This wasn't noticed earlier [..] because netfilter ip defrag did not=
 set local_df
> until couple of days ago.'
>=20
> -stable lacks commit 895162b1101b3ea5db08ca6822ae9672717efec0, so
> netfilter never sets ->local_df.  Thus all defragmented packets
> that go over the mtu are refused to be forwarded.
>=20
> Gergely, please either revert
>=20
> commit bd91cb56f951a7b0da8c3098ea9cd56854ece66c
> Author: Florian Westphal <fw@strlen.de>
> net: ipv4: ip_forward: fix inverted local_df test
> [ Upstream commit ca6c5d4ad216d5942ae544bbf02503041bd802aa ]
>=20
> Or, alternatively, also apply upstream commit 895162b1101b3ea5db08ca6=
822ae9672717efec0
> Author: Florian Westphal <fw@strlen.de>
> Date:   Fri May 2 15:32:16 2014 +0200
> netfilter: ipv4: defrag: set local_df flag on defragmented skb
>=20
> on top of your 3.4.92 kernel.
>=20
> (The latter might be a better option since it will also fix the
>  long-standing issue where netfilter sends bogus frag-needed message
>  under very rare circumstances).

I believe, the same holds for 3.12, right? (I have just applied "defrag=
:
set local_df flag on defragmented skb".)

thanks,
--=20
js
suse labs

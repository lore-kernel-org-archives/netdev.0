From: Daniel Baluta <dbaluta@ixiacom.com>
Subject: Re: [RFC PATCH 0/4] inet: add second hash table
Date: Wed, 30 May 2012 15:32:44 +0300
Message-ID: <CAEnQRZD3o_+fRnnbd74VeFuNvjAVVyq-rE241J96iRXWFDAEPQ@mail.gmail.com>
References: <1338363410-6562-1-git-send-email-alex.mihai.c@gmail.com>
	<1338364640.2760.96.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexandru Copot <alex.mihai.c@gmail.com>, davem@davemloft.net,
	gerrit@erg.abdn.ac.uk, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	Lucian Grijincu <lucian.grijincu@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:63931 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753314Ab2E3Mcp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 08:32:45 -0400
Received: by vbbff1 with SMTP id ff1so3205614vbb.19
        for <netdev@vger.kernel.org>; Wed, 30 May 2012 05:32:45 -0700 (PDT)
In-Reply-To: <1338364640.2760.96.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 30, 2012 at 10:57 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> On Wed, 2012-05-30 at 10:36 +0300, Alexandru Copot wrote:
>> This patchset implements all the operations needed to use a second
>> (port,address) bind hash table for inet. It uses a similar approach
>> as the UDP implementation.
>>
>> The performance improvements for port allocation are very good and
>> detailed in the last message.
>>
>> This is based on a series of patches written by Lucian Grijincu at I=
xia.
>>
>> Signed-off-by: Alexandru Copot <alex.mihai.c@gmail.com>
>> Cc: Daniel Baluta <dbaluta@ixiacom.com>
>> Cc: Lucian Grijincu <lucian.grijincu@gmail.com>
>> ---
>> Alexandru Copot (4):
>> =A0 =A0 =A0 inet: add counter to inet_bind_hashbucket
>> =A0 =A0 =A0 inet: add a second bind hash
>> =A0 =A0 =A0 inet: add/remove inet buckets in the second bind hash
>> =A0 =A0 =A0 inet: use second hash in inet_csk_get_port
>>
>> =A0include/net/inet_hashtables.h =A0 =A0| =A0140 +++++++++++++++++++=
++++++++++++--
>> =A0include/net/inet_timewait_sock.h | =A0 =A05 +-
>> =A0net/dccp/proto.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 37 +++++++=
+-
>> =A0net/ipv4/inet_connection_sock.c =A0| =A0 66 ++++++++--------
>> =A0net/ipv4/inet_hashtables.c =A0 =A0 =A0 | =A0158 +++++++++++++++++=
+++++++++++++++++++--
>> =A0net/ipv4/inet_timewait_sock.c =A0 =A0| =A0 16 ++--
>> =A0net/ipv4/tcp.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 17 ++++
>> =A0net/ipv6/inet6_hashtables.c =A0 =A0 =A0| =A0 95 +++++++++++++++++=
++++++
>> =A08 files changed, 477 insertions(+), 57 deletions(-)
>
>
> Its a huge change (with many details to look at), for a yet to be
> understood need.
>
> What sensible workload needs this at all ?

Hi Eric,

Usually our tests use a huge number of virtual interfaces.
Using this patch we get a massive improvement when there are many socke=
ts
bound to the same port, but different addresses for both bind() and
listen() system calls (both call inet_csk_get_port).
=09
We provided some data points in the fourth patch:

=46or 16.000 interfaces each with a distinct IPv4 address, doing bind
and then listen we get:

* Without patch and without SO_REUSEADDR:
   * bind:   1.543 s
   * listen: 3.050 s

* Without patch and with SO_REUSEADDR set:
   * bind:   0.066 s
   * listen: 3.050 s

* With patch and SO_REUSEADDR set / without SO_REUSEADDR:
   * bind:   0.066 s
   * listen: 0.095 s

The source code for tests can be found here [1].
Just run:
* ./prepare_test2.sh
* ./avg_tcp.sh

If I understood it correctly, a similar patch was introduced
for UDP some time ago. [2]

thanks,
Daniel.

[1] http://ixlabs.cs.pub.ro/gitweb/?p=3Dport-allocation.git;a=3Dtree;f=3D=
testbind;h=3D687e4452101e13cb5995b43c1351d76786d98fdd;hb=3DHEAD
[2] http://www.spinics.net/lists/netdev/msg112056.html

From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next] netlink: fix compilation after memory mapped patches
Date: Tue, 23 Apr 2013 09:55:49 -0700
Message-ID: <877gjtuqy2.fsf@xmission.com>
References: <1366707353-32434-1-git-send-email-nicolas.dichtel@6wind.com>
	<1366734263.4016.32.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <kaber@trash.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:43949 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756358Ab3DWQ4F convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 12:56:05 -0400
In-Reply-To: <1366734263.4016.32.camel@bwh-desktop.uk.solarflarecom.com> (Ben
	Hutchings's message of "Tue, 23 Apr 2013 17:24:23 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <bhutchings@solarflare.com> writes:

> On Tue, 2013-04-23 at 10:55 +0200, Nicolas Dichtel wrote:
>> Depending of the kernel configuration (CONFIG_UIDGID_STRICT_TYPE_CHE=
CKS), we can
>> get the following errors:
>>=20
>> net/netlink/af_netlink.c: In function =E2=80=98netlink_queue_mmaped_=
skb=E2=80=99:
>> net/netlink/af_netlink.c:663:14: error: incompatible types when assi=
gning to type =E2=80=98__u32=E2=80=99 from type =E2=80=98kuid_t=E2=80=99
>> net/netlink/af_netlink.c:664:14: error: incompatible types when assi=
gning to type =E2=80=98__u32=E2=80=99 from type =E2=80=98kgid_t=E2=80=99
>> net/netlink/af_netlink.c: In function =E2=80=98netlink_ring_set_copi=
ed=E2=80=99:
>> net/netlink/af_netlink.c:693:14: error: incompatible types when assi=
gning to type =E2=80=98__u32=E2=80=99 from type =E2=80=98kuid_t=E2=80=99
>> net/netlink/af_netlink.c:694:14: error: incompatible types when assi=
gning to type =E2=80=98__u32=E2=80=99 from type =E2=80=98kgid_t=E2=80=99
>>=20
>> We must use the helpers to get the uid and gid.
>>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> ---
>>  net/netlink/af_netlink.c | 8 ++++----
>>  1 file changed, 4 insertions(+), 4 deletions(-)
>>=20
>> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
>> index 2a3e9ba..0593a9a 100644
>> --- a/net/netlink/af_netlink.c
>> +++ b/net/netlink/af_netlink.c
>> @@ -660,8 +660,8 @@ static void netlink_queue_mmaped_skb(struct sock=
 *sk, struct sk_buff *skb)
>>  	hdr->nm_len	=3D skb->len;
>>  	hdr->nm_group	=3D NETLINK_CB(skb).dst_group;
>>  	hdr->nm_pid	=3D NETLINK_CB(skb).creds.pid;
>> -	hdr->nm_uid	=3D NETLINK_CB(skb).creds.uid;
>> -	hdr->nm_gid	=3D NETLINK_CB(skb).creds.gid;
>> +	hdr->nm_uid	=3D __kuid_val(NETLINK_CB(skb).creds.uid);
>> +	hdr->nm_gid	=3D __kgid_val(NETLINK_CB(skb).creds.gid);
>
> Shouldn't these use from_k{u,g}id_munged() like scm_recv() does?

Most definitely.

__kuid_val and __kgid_val are implementation details you probably don't
want to be messing with.

So I think what the code wants to say is:
hdr->nm_uid =3D from_kuid(sk_user_ns(sk), NETLINK_CB(skb).creds.uid);
hdr->nm_gid =3D from_kgid(sk_user_ns(sk), NETLINK_CB(skb).creds.gid);

A rather frustrated part of me wonders if anyone uses netlink sockets
between userspace processes.  If not we could just make all of this
credential passing go away.

And there is something more that should be done with pids but netlink
is so twisty I haven't figured out how to make netlink sockets properly
pass pids between pid namespaces.

Eric

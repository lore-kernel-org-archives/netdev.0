From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] ip: Report qdisc packet drops
Date: Thu, 03 Sep 2009 16:12:21 +0200
Message-ID: <4A9FCEC5.80409@gmail.com>
References: <4A98132C.8090105@gmail.com> <20090828.233858.256193304.davem@davemloft.net> <4A9BBD8E.2010303@gmail.com> <20090901.184121.06750444.davem@davemloft.net> <4A9E849A.30105@gmail.com> <4A9EF113.9030102@gmail.com> <alpine.DEB.1.10.0909031255490.27903@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, sri@us.ibm.com,
	dlstevens@us.ibm.com, netdev@vger.kernel.org,
	niv@linux.vnet.ibm.com, mtk.manpages@gmail.com
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35984 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755336AbZICOM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 10:12:29 -0400
In-Reply-To: <alpine.DEB.1.10.0909031255490.27903@V090114053VZO-1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> On Thu, 3 Sep 2009, Eric Dumazet wrote:
>> index 29ebb0d..ebaaa7f 100644
>> --- a/net/ipv4/udp.c
>> +++ b/net/ipv4/udp.c
>> @@ -561,12 +561,18 @@ static int udp_push_pending_frames(struct sock=
 *sk)
>>
>>  send:
>>  	err =3D ip_push_pending_frames(sk);
>> +	if (err) {
>> +		if (err =3D=3D -ENOBUFS && !inet->recverr) {
>> +			UDP_INC_STATS_USER(sock_net(sk),
>> +					   UDP_MIB_SNDBUFERRORS, is_udplite);
>=20
> This means that we now do not increment SNDBUFERRORS if IP_RECVERR is=
 set.
>=20
> I think it would be better to move UDP_INC_STATS_USER before the if
> statement. That will also simplify the code further.
>=20
>=20

I believe you already said this once Christoph on a previous patch, and=
 I=20
replied that in case of IP_RECVERR set, udp_push_pending_frames()
returns -ENOBUFS to its caller : udp_sendmsg()

And the caller takes care of :

out:
        ip_rt_put(rt);
        if (free)
                kfree(ipc.opt);
        if (!err)
                return len;
        /*
         * ENOBUFS =3D no kernel mem, SOCK_NOSPACE =3D no sndbuf space.=
  Reporting
         * ENOBUFS might not be good (it's not tunable per se), but oth=
erwise
         * we don't have a good statistic (IpOutDiscards but it can be =
too many
         * things).  We could add another new stat but at least for now=
 that
         * seems like overkill.
         */
        if (err =3D=3D -ENOBUFS || test_bit(SOCK_NOSPACE, &sk->sk_socke=
t->flags)) {
                UDP_INC_STATS_USER(sock_net(sk),
                                UDP_MIB_SNDBUFERRORS, is_udplite);
        }
        return err;



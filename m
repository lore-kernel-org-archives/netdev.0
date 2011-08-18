From: krbmit siso <krbmit@gmail.com>
Subject: Re: protect raw sockets
Date: Thu, 18 Aug 2011 20:31:08 +0530
Message-ID: <CABjs8yVOgKBrF2dMopzPmsfouWz5WHCAZCqjG3nY76CaqTFRLw@mail.gmail.com>
References: <A2354B6A9F807641B21EEABD666ECEEA011AFCE2@XMB-BGL-416.cisco.com>
	<CABjs8yWMgyyPHC1Nfgs2TZ1ixN7Khq0OimEhUhTs-Ux_9LAx5g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, ipsec-tools-users@lists.sourceforge.net,
	ipsec-tools-devel@lists.sourceforge.net,
	ikev2-devel@lists.sourceforge.net,
	=?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:53424 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755006Ab1HRPBJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2011 11:01:09 -0400
Received: by gxk21 with SMTP id 21so1533904gxk.19
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2011 08:01:09 -0700 (PDT)
In-Reply-To: <CABjs8yWMgyyPHC1Nfgs2TZ1ixN7Khq0OimEhUhTs-Ux_9LAx5g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,
After adding the below code in net/ipv4/raw.c in function raw_send_hdri=
nc()
I am able to see packet sent using RAW_SOCKET getting protected .

Please  let me know how can it be done better and provide it has a feat=
ure
, so that others can also use it  if  packet sent using RAW_SOCKET
needs to be protected.

/**************  net/ipv4/raw.c *************/
  struct flowi fl;
        struct dst_entry *dst;
        int res;

        if (xfrm_decode_session(skb, &fl, AF_INET)<0){

        printk("\n xfrm_decode_session FAILED \n");
                XFRM_INC_STATS(net, LINUX_MIB_XFRMFWDHDRERROR);
                return 0;
        }

        dst =3D skb_dst(skb);

        printk("\n xfrm_lookup called \n");
        res =3D xfrm_lookup(net, &dst, &fl, NULL, 0) =3D=3D 0;
        skb_dst_set(skb, dst);

       err =3D NF_HOOK(PF_INET, NF_INET_LOCAL_OUT, skb, NULL, rt->u.dst=
=2Edev,
                      dst_output);
/*************************************************/

Thanks and Regards
Naveen

On Thu, Aug 18, 2011 at 1:58 PM, krbmit siso <krbmit@gmail.com> wrote:
> Hi Timo,
>
> Thanks for your reply .
> Yes i did explore this yesterday and i was successful in sending the =
IKE
> messages unprotected after using the below code only for UDP sockets.
>
> int setsockopt_bypass(int fd, int family)
> {
> =A0 =A0 =A0 =A0struct sadb_x_policy policy;
> =A0 =A0 =A0 =A0int level, optname;
>
> =A0 =A0 =A0 =A0switch (family) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case AF_INET:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0level =3D IPPROTO_IP;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0optname =3D IP_IPSEC_P=
OLICY;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case AF_INET6:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0level =3D IPPROTO_IPV6=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0optname =3D IPV6_IPSEC=
_POLICY;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0default:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -1;
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0memset(&policy, 0, sizeof(policy));
> =A0 =A0 =A0 =A0policy.sadb_x_policy_len =3D PFKEY_UNIT64(sizeof(polic=
y));
> =A0 =A0 =A0 =A0policy.sadb_x_policy_exttype =3D SADB_X_EXT_POLICY;
> =A0 =A0 =A0 =A0policy.sadb_x_policy_type =3D IPSEC_POLICY_BYPASS;
> =A0 =A0 =A0 =A0policy.sadb_x_policy_dir =3D IPSEC_DIR_INBOUND;
> =A0 =A0 =A0 =A0if (setsockopt(fd, level, optname, &policy, sizeof(pol=
icy)) =3D=3D -1) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -1;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0policy.sadb_x_policy_dir =3D IPSEC_DIR_OUTBOUND;
> =A0 =A0 =A0 =A0if (setsockopt(fd, level, optname, &policy, sizeof(pol=
icy)) =3D=3D -1) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -1;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0return 0;
> }
>
> But i did try the same on RAW socket by setting the policy has
> policy.sadb_x_policy_type =3D IPSEC_POLICY_ENTRUST|IPSEC_POLICY_IPSEC=
;
> But the packet is going unprotected .
> Please show some light on how to protect RAW packets if there is a Po=
licy
> matching in the SPD saying it need to be protected.
> I have checked the posting there is no help on this isues , could
> you please give some options , if it is possible from Application.
>
>
> Thanks and Regards
> Naveen
>
> On Thu, Aug 18, 2011 at 1:45 PM, Naveen B N (nbn) <nbn@cisco.com> wro=
te:
>> Hi All,
>> Is there a way to enforce IPsec protection for packets sent from
>> application using RAW_SOCKET.
>>
>> My analysis is to add a code at the raw_sendmsg() & raw_v4_input() t=
o
>> call xfrm_policy_check() ..
>> Is it a good method to proceed or is there a better and smart way to
>> achieve this .
>>
>> Hoping for some guide lines ..
>>
>> Thanks in advance ..
>>
>> Thanks and Regards
>> Naveen
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>>
>

From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: Re: [PATCH] x25: Validate incoming call user data lengths
Date: Thu, 6 Oct 2011 07:09:31 +1100
Message-ID: <CADo0ohgP70GgrSfg3MUqS4juZ=wQa_Lz4=UM=1OAzEbh_f4ZSg@mail.gmail.com>
References: <CA+nUz_J73agjPQPqdbTraUPLyv39sqQ4kvZTmrZrFXLW1faqwg@mail.gmail.com>
	<1317738819.2440.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matthew Daley <mattjd@gmail.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:52587 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935116Ab1JEUJc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 16:09:32 -0400
Received: by vws1 with SMTP id 1so1667143vws.19
        for <netdev@vger.kernel.org>; Wed, 05 Oct 2011 13:09:31 -0700 (PDT)
In-Reply-To: <1317738819.2440.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ran this on a few systems and put a few GB through it, looks good.

Tested-by: Andrew Hendry <andrew.hendry@gmail.com>

On Wed, Oct 5, 2011 at 1:33 AM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le mardi 04 octobre 2011 =E0 14:00 +0000, Matthew Daley a =E9crit :
>> X.25 call user data is being copied in its entirety from incoming me=
ssages
>> without consideration to the size of the destination buffers, leadin=
g to
>> possible buffer overflows. Validate incoming call user data lengths =
before
>> these copies are performed.
>>
>> It appears this issue was noticed some time ago, however nothing see=
med to
>> come of it: see http://www.spinics.net/lists/linux-x25/msg00043.html=
 and
>> commit 8db09f26f912f7c90c764806e804b558da520d4f.
>>
>> Signed-off-by: Matthew Daley <mattjd@gmail.com>
>> Cc: Eric Dumazet <eric.dumazet@gmail.com>
>> Cc: Andrew Hendry <andrew.hendry@gmail.com>
>> Cc: stable <stable@kernel.org>
>> ---
>> Hopefully this is acceptable; I thought someone with greater knowled=
ge of
>> X.25 might step in :) It should take into account Andrew's suggestio=
n to
>> move af_x25.c's check to before the call acception.
>>
>> =A0net/x25/af_x25.c | =A0 =A06 ++++++
>> =A0net/x25/x25_in.c | =A0 =A03 +++
>> =A02 files changed, 9 insertions(+), 0 deletions(-)
>>
>> diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
>> index d306154..a4bd172 100644
>> --- a/net/x25/af_x25.c
>> +++ b/net/x25/af_x25.c
>> @@ -959,6 +959,12 @@ int x25_rx_call_request(struct sk_buff *skb,
>> struct x25_neigh *nb,
>> =A0 =A0 =A0 skb_pull(skb,len);
>>
>> =A0 =A0 =A0 /*
>> + =A0 =A0 =A0* =A0 =A0 =A0Ensure that the amount of call user data i=
s valid.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 if (skb->len > X25_MAX_CUD_LEN)
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out_clear_request;
>> +
>> + =A0 =A0 /*
>> =A0 =A0 =A0 =A0* =A0 =A0 =A0Find a listener for the particular addre=
ss/cud pair.
>> =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 sk =3D x25_find_listener(&source_addr,skb);
>> diff --git a/net/x25/x25_in.c b/net/x25/x25_in.c
>> index 0b073b5..63488fd 100644
>> --- a/net/x25/x25_in.c
>> +++ b/net/x25/x25_in.c
>> @@ -127,6 +127,9 @@ static int x25_state1_machine(struct sock *sk,
>> struct sk_buff *skb, int frametyp
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* =A0 =A0 =A0Copy any Call User Data.
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (skb->len > 0) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (skb->len > X25_MAX_CUD=
_LEN)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_c=
lear;
>> +
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_copy_from_linear_dat=
a(skb,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 x25->calluserdata.cuddata,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->len);
>> --
>
> It seems fine to me.
>
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>
> Now, you could also fix x25 for undersized/frags frames :
>
> Apparently, no check is done in this respect (missing pskb_may_pull()
> calls)...
>
>
>
>

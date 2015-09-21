From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: [PATCH] lib: fix data race in rhashtable_rehash_one
Date: Mon, 21 Sep 2015 17:10:06 +0200
Message-ID: <CACT4Y+ZSGBi00ZbCN6NE=NdJ7Lm76LVjkSFMsC5diLHHD66Cfw@mail.gmail.com>
References: <1442822930-35319-1-git-send-email-dvyukov@google.com>
 <1442842315.29850.44.camel@edumazet-glaptop2.roam.corp.google.com> <1442847108.29850.56.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tgraf@suug.ch, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Kostya Serebryany <kcc@google.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Alexander Potapenko <glider@google.com>,
	ktsan@googlegroups.com, Paul McKenney <paulmck@linux.vnet.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442847108.29850.56.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 21, 2015 at 4:51 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> On Mon, 2015-09-21 at 06:31 -0700, Eric Dumazet wrote:
>> On Mon, 2015-09-21 at 10:08 +0200, Dmitry Vyukov wrote:
>> > rhashtable_rehash_one() uses plain writes to update entry->next,
>> > while it is being concurrently accessed by readers.
>> > Unfortunately, the compiler is within its rights to (for example) =
use
>> > byte-at-a-time writes to update the pointer, which would fatally c=
onfuse
>> > concurrent readers.
>> >
>> This is bogus.
>>
>> 1) Linux is certainly not working if some arch or compiler is not do=
ing
>> single word writes. WRITE_ONCE() would not help at all to enforce th=
is.
>>
>> 2) If  new node is not yet visible, we don't care if we write
>> entry->next using any kind of operation.
>>
>> So the WRITE_ONCE() is not needed at all.
>>
>>
>>
>> > +   WRITE_ONCE(entry->next, head);
>>
>>
>> The rcu_assign_pointer() immediately following is enough in this cas=
e.
>>
>> We have hundred of similar cases in the kernel.
>>
>>
>
> The changelog and comment are totally confusing.
>
> Please remove the bogus parts in them, and/or rephrase.
>
> The important part here is that we rehash an item, so we need to make
> sure to maintain consistent ->next field, and need to prevent compile=
r
> from using ->next as a temporary variable.
>
> ptr->next =3D 1UL | ((base + offset) << 1);
>
> Is dangerous because compiler could issue :
>
> ptr->next =3D (base + offset);
>
> ptr->next <<=3D 1;
>
> ptr->next +=3D 1UL;
>
> Frankly, all this looks like an oversight in this code.
>
> Not sure why the NULLS value is even recomputed.

I have not looked in detail yet, but the NULLS recomputation uses
new_hash, which obviously wasn't available when the value was
previously computed. Don't know yet whether it is important or not.



>
> diff --git a/lib/rhashtable.c b/lib/rhashtable.c
> index cc0c69710dcf..0a29f07ba45a 100644
> --- a/lib/rhashtable.c
> +++ b/lib/rhashtable.c
> @@ -187,10 +187,7 @@ static int rhashtable_rehash_one(struct rhashtab=
le *ht, unsigned int old_hash)
>         head =3D rht_dereference_bucket(new_tbl->buckets[new_hash],
>                                       new_tbl, new_hash);
>
> -       if (rht_is_a_nulls(head))
> -               INIT_RHT_NULLS_HEAD(entry->next, ht, new_hash);
> -       else
> -               RCU_INIT_POINTER(entry->next, head);
> +       RCU_INIT_POINTER(entry->next, head);
>
>         rcu_assign_pointer(new_tbl->buckets[new_hash], entry);
>         spin_unlock(new_bucket_lock);
>
>
> --
> You received this message because you are subscribed to the Google Gr=
oups "ktsan" group.
> To unsubscribe from this group and stop receiving emails from it, sen=
d an email to ktsan+unsubscribe@googlegroups.com.
> To post to this group, send email to ktsan@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/=
msgid/ktsan/1442847108.29850.56.camel%40edumazet-glaptop2.roam.corp.goo=
gle.com.
> For more options, visit https://groups.google.com/d/optout.



--=20
Dmitry Vyukov, Software Engineer, dvyukov@google.com
Google Germany GmbH, Dienerstra=C3=9Fe 12, 80331, M=C3=BCnchen
Gesch=C3=A4ftsf=C3=BChrer: Graham Law, Christine Elizabeth Flores
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
Diese E-Mail ist vertraulich. Wenn Sie nicht der richtige Adressat
sind, leiten Sie diese bitte nicht weiter, informieren Sie den
Absender und l=C3=B6schen Sie die E-Mail und alle Anh=C3=A4nge. Vielen =
Dank.
This e-mail is confidential. If you are not the right addressee please
do not forward it, please inform the sender, and please erase this
e-mail including any attachments. Thanks.

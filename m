From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Possible netfilter-related memory corruption in 2.6.37
Date: Fri, 18 Feb 2011 20:14:55 +0100
Message-ID: <1298056495.2425.26.camel@edumazet-laptop>
References: <4D594313.4050009@redhat.com>
	 <1297696283.2996.33.camel@edumazet-laptop>
	 <alpine.LNX.2.01.1102141617330.12050@obet.zrqbmnf.qr>
	 <1297698641.2996.38.camel@edumazet-laptop>  <4D595745.7070505@trash.net>
	 <1297700955.2996.40.camel@edumazet-laptop>  <4D595A48.9070201@trash.net>
	 <1297702128.2996.41.camel@edumazet-laptop> <4D595DBD.3090005@trash.net>
	 <4D5EBC6D.6070200@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Engelhardt <jengelh@medozas.de>, Avi Kivity <avi@redhat.com>,
	netfilter-devel@vger.kernel.org,
	Marcelo Tosatti <mtosatti@redhat.com>,
	nicolas prochazka <prochazka.nicolas@gmail.com>,
	KVM list <kvm@vger.kernel.org>, netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4D5EBC6D.6070200@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 18 f=C3=A9vrier 2011 =C3=A0 19:37 +0100, Patrick McHardy a =
=C3=A9crit :
> Am 14.02.2011 17:52, schrieb Patrick McHardy:
> > Am 14.02.2011 17:48, schrieb Eric Dumazet:
> >> I am not sure, but I guess nf_reinject() needs a fix too ;)
> >=20
> > I agree. That one looks uglier though, I guess we'll have to
> > iterate through all hooks to note the previous one.
>=20
> How about this? Unfortunately I don't think we can avoid
> iterating through all hooks without violating RCU rules.
>=20
>=20

       /* Continue traversal iff userspace said ok... */
        if (verdict =3D=3D NF_REPEAT) {
-               elem =3D elem->prev;
-               verdict =3D NF_ACCEPT;
+               prev =3D NULL;
+               list_for_each_entry_rcu(i,
&nf_hooks[entry->pf][entry->hook],
+                                       list) {
+                       if (&i->list =3D=3D elem)
+                               break;
+                       prev =3D i;

=09
Hmm... what happens if "elem" was the first elem in list ?

We exit with prev =3D NULL  --> NF_DROP ?

I must miss something...

+               }
+
+               if (prev =3D=3D NULL ||
+                   &i->list =3D=3D &nf_hooks[entry->pf][entry->hook])
+                       verdict =3D NF_DROP;
+               else {
+                       elem =3D &prev->list;
+                       verdict =3D NF_ACCEPT;
+               }
        }



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

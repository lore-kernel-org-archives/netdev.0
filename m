From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [take12 1/3] kevent: Core files.
Date: Wed, 23 Aug 2006 10:51:36 +0200
Message-ID: <200608231051.37089.dada1@cosmosbay.com>
References: <115615558935@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:54207 "EHLO pfx2.jmh.fr")
	by vger.kernel.org with ESMTP id S964791AbWHWIvg convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 04:51:36 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <115615558935@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Evgeniy

I have one comment/suggestion (minor detail, your work is very good)

I suggest to add one item in kevent_registered_callbacks[], so that=20
kevent_registered_callbacks[KEVENT_MAX] is valid and can act as a fallb=
ack.

In kevent_add_callbacks() you could replace the eventual NULL pointers =
by=20
kevent_break() in=20
kevent_registered_callbacks[pos].{callback, enqueue, dequeue}
like :

+int kevent_add_callbacks(const struct kevent_callbacks *cb, unsigned i=
nt pos)
+{
+	struct kevent_callbacks *p =3D &kevent_registered_callbacks[pos];
+       if (pos >=3D KEVENT_MAX)
+               return -EINVAL;
+      p->enqueue =3D (cb->enqueue) ? cb->enqueue : kevent_break;
+      p->dequeue =3D (cb->dequeue) ? cb->dequeue : kevent_break;
+      p->callback =3D (cb->callback) ? cb->callback : kevent_break;
+       printk(KERN_INFO "KEVENT: Added callbacks for type %u.\n", pos)=
;
+       return 0;
+}

(I also added a const qualifier in first function argument, and unsigne=
d int=20
pos so that the "if (pos >=3D KEVENT_MAX)" test catches 'negative' valu=
es)

Then you change kevent_break() to return -EINVAL instead of 0.

+int kevent_break(struct kevent *k)
+{
+=A0=A0=A0=A0=A0=A0=A0unsigned long flags;
+
+=A0=A0=A0=A0=A0=A0=A0spin_lock_irqsave(&k->ulock, flags);
+=A0=A0=A0=A0=A0=A0=A0k->event.ret_flags |=3D KEVENT_RET_BROKEN;
+=A0=A0=A0=A0=A0=A0=A0spin_unlock_irqrestore(&k->ulock, flags);
+=A0=A0=A0=A0=A0=A0=A0return -EINVAL;
+}

Then avoid the tests in kevent_enqueue()

+int kevent_enqueue(struct kevent *k)
+{
+=A0=A0=A0=A0=A0=A0=A0return k->callbacks.enqueue(k);
+}

And avoid the tests in  kevent_dequeue()

+int kevent_dequeue(struct kevent *k)
+{
+=A0=A0=A0=A0=A0=A0=A0return k->callbacks.dequeue(k);
+}

And change kevent_init() to

+int kevent_init(struct kevent *k)
+{
+=A0=A0=A0=A0=A0=A0=A0spin_lock_init(&k->ulock);
+=A0=A0=A0=A0=A0=A0=A0k->flags =3D 0;
+
+=A0=A0=A0=A0=A0=A0=A0if (unlikely(k->event.type >=3D KEVENT_MAX))
+               k->event.type =3D KEVENT_MAX;
+	=20
+
+=A0=A0=A0=A0=A0=A0=A0k->callbacks =3D kevent_registered_callbacks[k->e=
vent.type];
+=A0=A0=A0=A0=A0=A0=A0if (unlikely(k->callbacks.callback =3D=3D kevent_=
break))
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0return kevent_break(k);
+
+=A0=A0=A0=A0=A0=A0=A0return 0;
+}



Eric Dumazet

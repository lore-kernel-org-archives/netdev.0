From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 08/11] netlink: implement memory mapped sendmsg()
Date: Thu, 08 Sep 2011 11:33:09 +0200
Message-ID: <4E688BD5.5030909@trash.net>
References: <1315070771-18576-1-git-send-email-kaber@trash.net> <1315070771-18576-9-git-send-email-kaber@trash.net> <20110904161822.GA8176@rere.qmqm.pl> <4E678C18.1010306@trash.net> <20110907200319.GA29545@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq@rere.qmqm.pl>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20110907200319.GA29545@rere.qmqm.pl>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 07.09.2011 22:03, schrieb Micha=B3 Miros=B3aw:
> On Wed, Sep 07, 2011 at 05:22:00PM +0200, Patrick McHardy wrote:
>> On 04.09.2011 18:18, Micha=B3 Miros=B3aw wrote:
>>> On Sat, Sep 03, 2011 at 07:26:08PM +0200, kaber@trash.net wrote:
>>>> From: Patrick McHardy <kaber@trash.net>
>>>>
>>>> Add support for memory mapped sendmsg() to netlink. Userspace queu=
ed to
>>>> be processed frames into the TX ring and invokes sendmsg with
>>>> msg.iov.iov_base =3D NULL to trigger processing of all pending mes=
sages.
>>>>
>>>> Since the kernel usually performs full message validation before b=
eginning
>>>> processing, userspace must be prevented from modifying the message
>>>> contents while the kernel is processing them. In order to do so, t=
he
>>>> frames contents are copied to an allocated skb in case the the rin=
g is
>>>> mapped more than once or the file descriptor is shared (f.i. throu=
gh
>>>> AF_UNIX file descriptor passing).
>>>>
>>>> Otherwise an skb without a data area is allocated, the data pointe=
r set
>>>> to point to the data area of the ring frame and the skb is process=
ed.
>>>> Once the skb is freed, the destructor releases the frame back to u=
serspace
>>>> by setting the status to NL_MMAP_STATUS_UNUSED.
>>>
>>> Is this protected from threads? Like: one thread waits on sendmsg()=
 and
>>> another (same process) changes the buffer.
>> Yes, if the ring is mapped multiple times (or the file descriptor
>> is changed), the contents are copied to an allocated skb.
>=20
> I mean:
>=20
> [1] mmap()
> [1] fill buffers
> [1] pthread_create() [creates: 2]
> [1] sendmsg() starts
> [2] modify buffers
> [1] sendmsg() returns
>=20
> So: no multiple mmaps, and no touching of the fd. I haven't dug into
> filesystem layer to see if threads affect file->f_count, but there
> sure are no multiple mappings here.

If CLONE_VM is given to clone(), the mapping is visible in both
threads and thus we have multiple mappings (vma_ops->open() is
invoked through clone()). Without CLONE_VM, the second thread
can't access the ring unless it mmap()s it itself, in case we'd
also have multiple mappings.

The file descriptor check is only meant for the case that
the fd is passed to a second process through AF_UNIX, the
first process invokes sendmsg(), sendmsg() checks for multiple
mappings and the second process invokes mmap() after that.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

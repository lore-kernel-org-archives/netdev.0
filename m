From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] xprtrdma: silence frame size warning
Date: Mon, 13 Jan 2014 11:17:19 -0500
Message-ID: <D3560A1A-59B3-4480-8627-9114A4B9895C@oracle.com>
References: <1389627955.20467.9.camel@x41> <CDD9CEF2-F91A-4ABA-8DA7-53AF8A749194@primarydata.com>
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	"Miller David S." <davem@davemloft.net>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	netdev@vger.kernel.org, LKML Kernel <linux-kernel@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
	Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CDD9CEF2-F91A-4ABA-8DA7-53AF8A749194@primarydata.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi-

On Jan 13, 2014, at 10:59 AM, Trond Myklebust <trond.myklebust@primaryd=
ata.com> wrote:

>=20
> On Jan 13, 2014, at 10:45, Paul Bolle <pebolle@tiscali.nl> wrote:
>=20
>> Building verbs.o on 32 bits x86, with CONFIG_FRAME_WARN set to 1024,=
 its
>> default value, triggers this GCC warning:
>>   net/sunrpc/xprtrdma/verbs.c: In function =91rpcrdma_register_defau=
lt_external=92:
>>   net/sunrpc/xprtrdma/verbs.c:1774:1: warning: the frame size of 104=
0 bytes is larger than 1024 bytes [-Wframe-larger-than=3D]
>>=20
>> Silence this warning by allocating "ipb" dynamically.
>>=20
>> Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
>> ---
>> 0) Compile tested only (on 32 bits x86). I don't have access to
>> Infiniband hardware.
>>=20
>> 1) Please note that this is not a new warning. The oldest build log =
I
>> have still available on this machine is for a v3.8 rc, and it alread=
y
>> showed this warning.=20
>>=20
>> 2) I do hope my choice for the GFP_KERNEL flag is correct here.
>>=20
>> net/sunrpc/xprtrdma/verbs.c | 6 +++++-
>> 1 file changed, 5 insertions(+), 1 deletion(-)
>>=20
>> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs=
=2Ec
>> index 93726560..939ccc8 100644
>> --- a/net/sunrpc/xprtrdma/verbs.c
>> +++ b/net/sunrpc/xprtrdma/verbs.c
>> @@ -1736,11 +1736,14 @@ rpcrdma_register_default_external(struct rpc=
rdma_mr_seg *seg,
>> 	int mem_priv =3D (writing ? IB_ACCESS_REMOTE_WRITE :
>> 				  IB_ACCESS_REMOTE_READ);
>> 	struct rpcrdma_mr_seg *seg1 =3D seg;
>> -	struct ib_phys_buf ipb[RPCRDMA_MAX_DATA_SEGS];
>> +	struct ib_phys_buf *ipb;
>> 	int len, i, rc =3D 0;
>>=20
>> 	if (*nsegs > RPCRDMA_MAX_DATA_SEGS)
>> 		*nsegs =3D RPCRDMA_MAX_DATA_SEGS;
>> +	ipb =3D kmalloc(sizeof(*ipb) * *nsegs, GFP_KERNEL);
>> +	if (ipb =3D=3D NULL)
>> +		return -ENOMEM;
>> 	for (len =3D 0, i =3D 0; i < *nsegs;) {
>> 		rpcrdma_map_one(ia, seg, writing);
>> 		ipb[i].addr =3D seg->mr_dma;
>> @@ -1770,6 +1773,7 @@ rpcrdma_register_default_external(struct rpcrd=
ma_mr_seg *seg,
>> 		seg1->mr_len =3D len;
>> 	}
>> 	*nsegs =3D i;
>> +	kfree(ipb);
>> 	return rc;
>> }
>=20
> Hi Paul,
>=20
> Unfortunately, the above could be called from a file write back conte=
xt, so we cannot use GFP_KERNEL allocations. In fact, I suspect we shou=
ld only use GFP_ATOMIC, and then have the rpc_task delay and retry if t=
he allocation fails.
>=20
> The problem is that it looks to me as if xprt_rdma_send_request will =
currently fail, if we return an error from rpcrdma_register_default_ext=
ernal.
>=20
> Chuck, will you be able to look into the above issue as part of your =
RDMA work?

I=92m building a queue of NFS/RDMA work on bugzilla.kernel.org.  Let=92=
s create a defect report there to document this, and it will get priori=
tized with the rest.  Paul, can you do that to start us off?  Product =93=
=46ile system=94, Component =93NFS=94.

I can=92t say that a warning on 32-bit x86 is going to be an especially=
 high priority.  However, the underlying issue of allocating arrays of =
data segments on the stack is something that needs extended attention, =
and is already in plan.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

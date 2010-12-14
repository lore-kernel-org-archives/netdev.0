From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: [PATCH 12/12] cxgb4: NUMA-aware Tx queue allocations
Date: Tue, 14 Dec 2010 14:51:00 -0800
Message-ID: <4D07F4D4.5060809@chelsio.com>
References: <1292357896-14339-1-git-send-email-dm@chelsio.com>	 <1292357896-14339-2-git-send-email-dm@chelsio.com>	 <1292357896-14339-3-git-send-email-dm@chelsio.com>	 <1292357896-14339-4-git-send-email-dm@chelsio.com>	 <1292357896-14339-5-git-send-email-dm@chelsio.com>	 <1292357896-14339-6-git-send-email-dm@chelsio.com>	 <1292357896-14339-7-git-send-email-dm@chelsio.com>	 <1292357896-14339-8-git-send-email-dm@chelsio.com>	 <1292357896-14339-9-git-send-email-dm@chelsio.com>	 <1292357896-14339-10-git-send-email-dm@chelsio.com>	 <1292357896-14339-11-git-send-email-dm@chelsio.com>	 <1292357896-14339-12-git-send-email-dm@chelsio.com>	 <1292357896-14339-13-git-send-email-dm@chelsio.com> <1292361479.2478.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:24074 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758935Ab0LNWvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 17:51:06 -0500
In-Reply-To: <1292361479.2478.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le mardi 14 d=C3=A9cembre 2010 =C3=A0 12:18 -0800, Dimitris Michailid=
is a =C3=A9crit :
>> Allocate Tx queue memory on the node indicated by the new
>> netdev_queue_numa_node_read.  If that fails we allocate on any node.
>>
>> Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
>> ---
>>  drivers/net/cxgb4/sge.c |   20 +++++++++++++-------
>>  1 files changed, 13 insertions(+), 7 deletions(-)
>>
>> diff --git a/drivers/net/cxgb4/sge.c b/drivers/net/cxgb4/sge.c
>> index cc0b997..ed98b8a 100644
>> --- a/drivers/net/cxgb4/sge.c
>> +++ b/drivers/net/cxgb4/sge.c
>> @@ -579,6 +579,7 @@ static inline void __refill_fl(struct adapter *a=
dap, struct sge_fl *fl)
>>   *	@phys: the physical address of the allocated ring
>>   *	@metadata: address of the array holding the SW state for the rin=
g
>>   *	@stat_size: extra space in HW ring for status information
>> + *	@node: preferred node for memory allocations
>>   *
>>   *	Allocates resources for an SGE descriptor ring, such as Tx queue=
s,
>>   *	free buffer lists, or response queues.  Each SGE ring requires
>> @@ -590,7 +591,7 @@ static inline void __refill_fl(struct adapter *a=
dap, struct sge_fl *fl)
>>   */
>>  static void *alloc_ring(struct device *dev, size_t nelem, size_t el=
em_size,
>>  			size_t sw_size, dma_addr_t *phys, void *metadata,
>> -			size_t stat_size)
>> +			size_t stat_size, int node)
>>  {
>>  	size_t len =3D nelem * elem_size + stat_size;
>>  	void *s =3D NULL;
>> @@ -599,7 +600,10 @@ static void *alloc_ring(struct device *dev, siz=
e_t nelem, size_t elem_size,
>>  	if (!p)
>>  		return NULL;
>>  	if (sw_size) {
>> -		s =3D kcalloc(nelem, sw_size, GFP_KERNEL);
>> +		if (node >=3D 0)
>> +			s =3D kzalloc_node(nelem * sw_size, GFP_KERNEL, node);
>=20
> kzalloc_node() has a fallback, you dont need to retry with kcalloc()

I took this retry part from ixgbe but I can remove it if it's not neede=
d.=20
Luckily it's the last patch in the series.

>=20
>> +		if (!s)
>> +			s =3D kcalloc(nelem, sw_size, GFP_KERNEL);
>> =20
>>  		if (!s) {
>>  			dma_free_coherent(dev, len, p, *phys);
>=20
> Also, I am not sure it is going to work, since we can setup XPS only
> after device being setup ?
>=20
> By the time your driver allocates rings, we probably read
> -1/NUMA_NO_NODE

XPS is available after registration.  The queues are allocated at open =
time,=20
if one configures XPS prior to that the allocations happen on the right=
=20
nodes.  I've tried this and this is the behavior I see.  It is true tha=
t=20
setting XPS after open doesn't affect the queue allocations.

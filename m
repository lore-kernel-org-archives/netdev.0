From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [BUG] overflow in net/ipv4/route.c rt_check_expire()
Date: Fri, 01 Apr 2005 23:43:38 +0200
Message-ID: <424DC08A.3020204@cosmosbay.com>
References: <42370997.6010302@cosmosbay.com>	<20050315103253.590c8bfc.davem@davemloft.net>	<42380EC6.60100@cosmosbay.com>	<20050316140915.0f6b9528.davem@davemloft.net>	<4239E00C.4080309@cosmosbay.com>	<20050331221352.13695124.davem@davemloft.net>	<424D5D34.4030800@cosmosbay.com>	<20050401122802.7c71afbc.davem@davemloft.net>	<424DB7A1.8090803@cosmosbay.com> <20050401130832.1f972a3b.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050401130832.1f972a3b.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller a =E9crit :
> On Fri, 01 Apr 2005 23:05:37 +0200
> Eric Dumazet <dada1@cosmosbay.com> wrote:
>=20
>=20
>>You mean you prefer :
>>
>>static spinlock_t   *rt_hash_lock ; /* rt_hash_lock =3D
>>alloc_memory_at_boot_time(...) */
>>
>>instead of
>>
>>static spinlock_t rt_hash_lock[RT_HASH_LOCK_SZ] ;
>>
>>In both cases, memory is taken from lowmem, and size of kernel image
>>is roughly the same (bss section takes no space in image)
>=20
>=20
> In the former case the kernel image the bootloader has to
> load is smaller.  That's important, believe it or not.  It
> means less TLB entries need to be locked permanently into
> the MMU on certain platforms.
>=20
>=20
OK thanks for this clarification. I changed to :

#if defined(CONFIG_SMP) || defined(CONFIG_DEBUG_SPINLOCK)
/*
  * Instead of using one spinlock for each rt_hash_bucket, we use a table=
 of spinlocks
  * The size of this table is a power of two and depends on the number of=
 CPUS.
  */
#if NR_CPUS >=3D 32
#define RT_HASH_LOCK_SZ 4096
#elif NR_CPUS >=3D 16
#define RT_HASH_LOCK_SZ 2048
#elif NR_CPUS >=3D 8
#define RT_HASH_LOCK_SZ 1024
#elif NR_CPUS >=3D 4
#define RT_HASH_LOCK_SZ 512
#else
#define RT_HASH_LOCK_SZ 256
#endif

         static spinlock_t       *rt_hash_locks;
# define rt_hash_lock_addr(slot) &rt_hash_locks[slot & (RT_HASH_LOCK_SZ -=
 1)]
# define rt_hash_lock_init()    { \
                 int i; \
                 rt_hash_locks =3D kmalloc(sizeof(spinlock_t) * RT_HASH_L=
OCK_SZ, GFP_KERNEL); \
                 if (!rt_hash_locks) panic("IP: failed to allocate rt_has=
h_locks\n"); \
                 for (i =3D 0; i < RT_HASH_LOCK_SZ; i++) \
                         spin_lock_init(&rt_hash_locks[i]); \
                 }
#else
# define rt_hash_lock_addr(slot) NULL
# define rt_hash_lock_init()
#endif


Are you OK if I also use alloc_large_system_hash() to allocate rt_hash_ta=
ble, instead of the current method ?
This new method is used in net/ipv4/tcp.c for tcp_ehash and tcp_bhash and=
 permits NUMA tuning.


Eric

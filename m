From: Wensong Zhang <wensong@linux-vs.org>
Subject: Re: [PATCH] (4/6) ipvs -- use reader locks and refcounts correctly.
Date: Thu, 18 Sep 2003 00:44:16 +0800 (CST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309180014470.15676-200000@penguin.linux-vs.org>
References: <20030916142116.58a05005.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463755008-979933807-1063817056=:15676"
Cc: lvs-users@LinuxVirtualServer.org, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030916142116.58a05005.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

---1463755008-979933807-1063817056=:15676
Content-Type: TEXT/PLAIN; charset=US-ASCII



Hi,

The locking change may be not very correct.

On Tue, 16 Sep 2003, Stephen Hemminger wrote:

> The code to get the service table was not taking a reader lock
> because it needed to copy_to_user.
> 
> Do it right:
> 	- hold refcnt when copying out, and use a read lock

There is no need to hold lock, because thread has already gained 
__ip_vs_mutex, there is no writer of service table, although net softirq 
may read service table, there is no conflict in reading the service table 
and copying out.

> 	- make lock local to ip_svc

Good.

> 	- get rid of IP_VS_WAIT_WHILE, use proper read locks and refcounts.

We have to use IP_VS_WAIT_WHILE to wait that all service users put back 
the service, because the user doesn't hold read locks all the time while 
using the service, it just increase the usecnt to indicate that the 
service is used and release the read lock immediately. Before the user put 
back the service, we cannot remove it.

> 	- move write_lock_bh in flush to outside of loop

Not necessary, because it has already hold __ip_vs_mutex, there is only 
one writer.

> 	- tag user pointers (for sparse).
> 

OK.

So, maybe we just apply the simple patch with making the lock local and 
tagging user pointers.

Thanks,

Wensong

> diff -Nru a/include/net/ip_vs.h b/include/net/ip_vs.h
> --- a/include/net/ip_vs.h	Tue Sep 16 14:08:55 2003
> +++ b/include/net/ip_vs.h	Tue Sep 16 14:08:55 2003
> @@ -319,8 +319,6 @@
>  #define LeaveFunction(level)   do {} while (0)
>  #endif
>  
> -#define	IP_VS_WAIT_WHILE(expr)	while (expr) { cpu_relax(); }
> -
>  
>  /*
>   *      The port number of FTP service (in network order).
> diff -Nru a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
> --- a/net/ipv4/ipvs/ip_vs_ctl.c	Tue Sep 16 14:08:55 2003
> +++ b/net/ipv4/ipvs/ip_vs_ctl.c	Tue Sep 16 14:08:55 2003
> @@ -48,7 +48,7 @@
>  static DECLARE_MUTEX(__ip_vs_mutex);
>  
>  /* lock for service table */
> -rwlock_t __ip_vs_svc_lock = RW_LOCK_UNLOCKED;
> +static rwlock_t __ip_vs_svc_lock = RW_LOCK_UNLOCKED;
>  
>  /* lock for table with the real services */
>  static rwlock_t __ip_vs_rs_lock = RW_LOCK_UNLOCKED;
> @@ -808,11 +808,6 @@
>  
>  		write_lock_bh(&__ip_vs_svc_lock);
>  
> -		/*
> -		 * Wait until all other svc users go away.
> -		 */
> -		IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 1);
> -
>  		list_add(&dest->n_list, &svc->destinations);
>  		svc->num_dests++;
>  
> @@ -838,11 +833,6 @@
>  
>  	write_lock_bh(&__ip_vs_svc_lock);
>  
> -	/*
> -	 * Wait until all other svc users go away.
> -	 */
> -	IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 1);
> -
>  	list_add(&dest->n_list, &svc->destinations);
>  	svc->num_dests++;
>  
> @@ -980,12 +970,6 @@
>  	}
>  
>  	write_lock_bh(&__ip_vs_svc_lock);
> -
> -	/*
> -	 *	Wait until all other svc users go away.
> -	 */
> -	IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 1);
> -
>  	/*
>  	 *	Unlink dest from the service
>  	 */
> @@ -1118,11 +1102,6 @@
>  	write_lock_bh(&__ip_vs_svc_lock);
>  
>  	/*
> -	 * Wait until all other svc users go away.
> -	 */
> -	IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 1);
> -
> -	/*
>  	 * Set the flags and timeout value
>  	 */
>  	svc->flags = u->flags | IP_VS_SVC_F_HASHED;
> @@ -1235,11 +1214,6 @@
>  
>  	ip_vs_svc_unhash(svc);
>  
> -	/*
> -	 * Wait until all the svc users go away.
> -	 */
> -	IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 1);
> -
>  	__ip_vs_del_service(svc);
>  
>  	write_unlock_bh(&__ip_vs_svc_lock);
> @@ -1259,16 +1233,11 @@
>  	/*
>  	 * Flush the service table hashed by <protocol,addr,port>
>  	 */
> +	write_lock_bh(&__ip_vs_svc_lock);
>  	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
>  		list_for_each_entry_safe(svc, nxt, &ip_vs_svc_table[idx], s_list) {
> -			write_lock_bh(&__ip_vs_svc_lock);
>  			ip_vs_svc_unhash(svc);
> -			/*
> -			 * Wait until all the svc users go away.
> -			 */
> -			IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 0);
>  			__ip_vs_del_service(svc);
> -			write_unlock_bh(&__ip_vs_svc_lock);
>  		}
>  	}
>  
> @@ -1278,16 +1247,11 @@
>  	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
>  		list_for_each_entry_safe(svc, nxt, 
>  					 &ip_vs_svc_fwm_table[idx], f_list) {
> -			write_lock_bh(&__ip_vs_svc_lock);
>  			ip_vs_svc_unhash(svc);
> -			/*
> -			 * Wait until all the svc users go away.
> -			 */
> -			IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 0);
>  			__ip_vs_del_service(svc);
> -			write_unlock_bh(&__ip_vs_svc_lock);
>  		}
>  	}
> +	write_unlock_bh(&__ip_vs_svc_lock);
>  
>  	return 0;
>  }
> @@ -1926,7 +1890,7 @@
>  
>  static inline int
>  __ip_vs_get_service_entries(const struct ip_vs_get_services *get,
> -			    struct ip_vs_get_services *uptr)
> +			    struct ip_vs_get_services __user *uptr)
>  {
>  	int idx, count=0;
>  	struct ip_vs_service *svc;
> @@ -1966,7 +1930,7 @@
>  
>  static inline int
>  __ip_vs_get_dest_entries(const struct ip_vs_get_dests *get,
> -			 struct ip_vs_get_dests *uptr)
> +			 struct ip_vs_get_dests __user *uptr)
>  {
>  	struct ip_vs_service *svc;
>  	int ret = 0;
> @@ -1981,6 +1945,7 @@
>  		struct ip_vs_dest *dest;
>  		struct ip_vs_dest_entry entry;
>  
> +		read_lock_bh(&__ip_vs_svc_lock);
>  		list_for_each_entry(dest, &svc->destinations, n_list) {
>  			if (count >= get->num_dests)
>  				break;
> @@ -1994,15 +1959,25 @@
>  			entry.activeconns = atomic_read(&dest->activeconns);
>  			entry.inactconns = atomic_read(&dest->inactconns);
>  			entry.persistconns = atomic_read(&dest->persistconns);
> +
>  			ip_vs_copy_stats(&entry.stats, &dest->stats);
> +
> +			atomic_inc(&dest->refcnt);
> +			read_unlock_bh(&__ip_vs_svc_lock);
>  			if (copy_to_user(&uptr->entrytable[count],
>  					 &entry, sizeof(entry))) {
>  				ret = -EFAULT;
>  				break;
>  			}
>  			count++;
> +
> +			read_lock_bh(&__ip_vs_svc_lock);
> +			if (atomic_dec_and_test(&dest->refcnt)) 
> +				kfree(dest);
> +
>  		}
>  		ip_vs_service_put(svc);
> +		read_unlock_bh(&__ip_vs_svc_lock);
>  	} else
>  		ret = -ESRCH;
>  	return ret;
> @@ -2043,7 +2018,7 @@
>  };
>  
>  static int
> -do_ip_vs_get_ctl(struct sock *sk, int cmd, void *user, int *len)
> +do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
>  {
>  	unsigned char arg[128];
>  	int ret = 0;
> 


---1463755008-979933807-1063817056=:15676
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="typetidyup.patch"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.44.0309180044160.15676@penguin.linux-vs.org>
Content-Description: 
Content-Disposition: attachment; filename="typetidyup.patch"

ZGlmZiAtTnJ1IGEvbmV0L2lwdjQvaXB2cy9pcF92c19jdGwuYyBiL25ldC9p
cHY0L2lwdnMvaXBfdnNfY3RsLmMNCi0tLSBhL25ldC9pcHY0L2lwdnMvaXBf
dnNfY3RsLmMgVGh1IFNlcCAxOCAwMDo0MzowMCAyMDAzDQorKysgYi9uZXQv
aXB2NC9pcHZzL2lwX3ZzX2N0bC5jIFRodSBTZXAgMTggMDA6NDM6MDAgMjAw
Mw0KQEAgLTQ2LDcgKzQ2LDcgQEANCiBzdGF0aWMgREVDTEFSRV9NVVRFWChf
X2lwX3ZzX211dGV4KTsNCiANCiAvKiBsb2NrIGZvciBzZXJ2aWNlIHRhYmxl
ICovDQotcndsb2NrX3QgX19pcF92c19zdmNfbG9jayA9IFJXX0xPQ0tfVU5M
T0NLRUQ7DQorc3RhdGljIHJ3bG9ja190IF9faXBfdnNfc3ZjX2xvY2sgPSBS
V19MT0NLX1VOTE9DS0VEOw0KIA0KIC8qIGxvY2sgZm9yIHRhYmxlIHdpdGgg
dGhlIHJlYWwgc2VydmljZXMgKi8NCiBzdGF0aWMgcndsb2NrX3QgX19pcF92
c19yc19sb2NrID0gUldfTE9DS19VTkxPQ0tFRDsNCkBAIC0xOTEyLDcgKzE5
MTIsNyBAQA0KIA0KIHN0YXRpYyBpbmxpbmUgaW50DQogX19pcF92c19nZXRf
c2VydmljZV9lbnRyaWVzKGNvbnN0IHN0cnVjdCBpcF92c19nZXRfc2Vydmlj
ZXMgKmdldCwNCi0gICAgICAgICAgICAgICAgICAgc3RydWN0IGlwX3ZzX2dl
dF9zZXJ2aWNlcyAqdXB0cikNCisgICAgICAgICAgICAgICAgICAgc3RydWN0
IGlwX3ZzX2dldF9zZXJ2aWNlcyBfX3VzZXIgKnVwdHIpDQogew0KICAgICAg
aW50IGlkeCwgY291bnQ9MDsNCiAgICAgIHN0cnVjdCBpcF92c19zZXJ2aWNl
ICpzdmM7DQpAQCAtMTk1NSw3ICsxOTU1LDcgQEANCiANCiBzdGF0aWMgaW5s
aW5lIGludA0KIF9faXBfdnNfZ2V0X2Rlc3RfZW50cmllcyhjb25zdCBzdHJ1
Y3QgaXBfdnNfZ2V0X2Rlc3RzICpnZXQsDQotICAgICAgICAgICAgICAgIHN0
cnVjdCBpcF92c19nZXRfZGVzdHMgKnVwdHIpDQorICAgICAgICAgICAgICAg
IHN0cnVjdCBpcF92c19nZXRfZGVzdHMgX191c2VyICp1cHRyKQ0KIHsNCiAg
ICAgIHN0cnVjdCBpcF92c19zZXJ2aWNlICpzdmM7DQogICAgICBpbnQgcmV0
ID0gMDsNCkBAIC0yMDM0LDcgKzIwMzQsNyBAQA0KIH07DQogDQogc3RhdGlj
IGludA0KLWRvX2lwX3ZzX2dldF9jdGwoc3RydWN0IHNvY2sgKnNrLCBpbnQg
Y21kLCB2b2lkICp1c2VyLCBpbnQgKmxlbikNCitkb19pcF92c19nZXRfY3Rs
KHN0cnVjdCBzb2NrICpzaywgaW50IGNtZCwgdm9pZCBfX3VzZXIgKnVzZXIs
IGludCAqbGVuKQ0KIHsNCiAgICAgIHVuc2lnbmVkIGNoYXIgYXJnWzEyOF07
DQogICAgICBpbnQgcmV0ID0gMDsNCg==
---1463755008-979933807-1063817056=:15676--

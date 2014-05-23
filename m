From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net] bridge: notify user space of fdb port
	change
Date: Fri, 23 May 2014 17:39:45 +0900
Message-ID: <537F0951.5010904@lab.ntt.co.jp>
References: <1399967708-7283-1-git-send-email-jmaxwell@redhat.com>
	<5372BA1E.8000402@lab.ntt.co.jp>
	<2052318198.6465872.1400101664337.JavaMail.zimbra@redhat.com>
	<1679971005.11740655.1400821172875.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, jpirko@redhat.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	stephen@networkplumber.org, Jon Maxwell <jmaxwell37@gmail.com>,
	davem@davemloft.net
To: Jon Maxwell <jmaxwell@redhat.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1679971005.11740655.1400821172875.JavaMail.zimbra@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

(2014/05/23 13:59), Jon Maxwell wrote:
...
> Makita-san,
> 
> I recoded this using your idea and ran it through a reproducer.
> It work fine. After some more consideration I agree that 
> setting fdb->dst = source is only required when source != fdb->dst.
> 
> Thanks for your suggestions. This is the revised patch. It should 
> retain the original behaviour except for the notify after the fdb update.  
> 
> Please let me know if you have any further input?

I have no more comments except for style problems (bracket position,
indentation, type mismatch).
thank you for rewriting :)

Thanks,
Toshiaki Makita

> 
> $ diff -Naur br_fdb.c br_fdb.c.patch
> --- br_fdb.c        2014-05-17 12:43:23.346319609 +1000
> +++ br_fdb.c.patch        2014-05-17 16:54:46.280235728 +1000
> @@ -487,6 +487,7 @@
>  {
>          struct hlist_head *head = &br->hash[br_mac_hash(addr, vid)];
>          struct net_bridge_fdb_entry *fdb;
> +        bool fdb_modified = 0;
>  
>          /* some users want to always flood. */
>          if (hold_time(br) == 0)
> @@ -507,10 +508,16 @@
>                                          source->dev->name);
>                  } else {
>                          /* fastpath: update of existing entry */
> -                        fdb->dst = source;
> +                        if (unlikely(source != fdb->dst))
> +                                {
> +                                fdb->dst = source;
> +                                fdb_modified = 1;
> +                                }
>                          fdb->updated = jiffies;
>                          if (unlikely(added_by_user))
>                                  fdb->added_by_user = 1;
> +                        if (unlikely(fdb_modified))
> +                                fdb_notify(br, fdb, RTM_NEWNEIGH);
>                  }
>          } else {
>                  spin_lock(&br->hash_lock);
> 
> 

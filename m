From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.21-rc7: BUG: sleeping function called from
	invalid context at net/core/sock.c:1523
Date: Tue, 24 Apr 2007 13:30:09 +1000
Message-ID: <E1HgBjF-0007Q9-00@gondolin.me.apana.org.au>
References: <Pine.LNX.4.64.0704232257090.20657@twin.jikos.cz>
Reply-To: BlueZ development <bluez-devel@lists.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jeremy@goop.org, netdev@vger.kernel.org, marcel@holtmann.org,
	gregkh@suse.de, linux-kernel@vger.kernel.org, clg@fr.ibm.com,
	bluez-devel@lists.sourceforge.net, maxk@qualcomm.com
To: jikos@jikos.cz (Jiri Kosina)
Return-path: <bluez-devel-bounces@lists.sourceforge.net>
In-Reply-To: <Pine.LNX.4.64.0704232257090.20657@twin.jikos.cz>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=bluez-devel>
List-Post: <mailto:bluez-devel@lists.sourceforge.net>
List-Help: <mailto:bluez-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: bluez-devel-bounces@lists.sourceforge.net
Errors-To: bluez-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Jiri Kosina <jikos@jikos.cz> wrote:
> 
> Hmm, *sigh*. I guess the patch below fixes the problem, but it is a 
> masterpiece in the field of ugliness. And I am not sure whether it is 
> completely correct either. Are there any immediate ideas for better 
> solution with respect to how struct sock locking works?

Please cc such patches to netdev.  Thanks.

> diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
> index 71f5cfb..c5c93cd 100644
> --- a/net/bluetooth/hci_sock.c
> +++ b/net/bluetooth/hci_sock.c
> @@ -656,7 +656,10 @@ static int hci_sock_dev_event(struct notifier_block *this, unsigned long event,
>                /* Detach sockets from device */
>                read_lock(&hci_sk_list.lock);
>                sk_for_each(sk, node, &hci_sk_list.head) {
> -                       lock_sock(sk);
> +                       if (in_atomic())
> +                               bh_lock_sock(sk);
> +                       else
> +                               lock_sock(sk);

This doesn't do what you think it does.  bh_lock_sock can still succeed
even with lock_sock held by someone else.

Does this need to occur immediately when an event occurs? If not I'd
suggest moving this into a workqueue.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/

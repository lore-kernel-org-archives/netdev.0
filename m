From: Alex Romosan <romosan@sycorax.lbl.gov>
Subject: Re: 2.6.19-rc1 regression: airo suspend fails
Date: Sat, 07 Oct 2006 13:17:13 -0700
Message-ID: <873b9zhody.fsf@sycorax.lbl.gov>
References: <Pine.LNX.4.64.0610042017340.3952@g5.osdl.org>
	<871wpmoyjv.fsf@sycorax.lbl.gov> <20061006184706.GR16812@stusta.de>
	<1160250771.24902.6.camel@kleikamp.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: linux-pm@osdl.org, netdev@vger.kernel.org, Adrian Bunk <bunk@stusta.de>,
   linux-kernel@vger.kernel.org
Return-path: <linux-pm-bounces@lists.osdl.org>
To: Dave Kleikamp <shaggy@austin.ibm.com>
In-Reply-To: <1160250771.24902.6.camel@kleikamp.austin.ibm.com> (message from
	Dave Kleikamp on Sat, 07 Oct 2006 14:52:51 -0500)
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/linux-pm>
List-Post: <mailto:linux-pm@lists.osdl.org>
List-Help: <mailto:linux-pm-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.osdl.org?subject=subscribe>
Sender: linux-pm-bounces@lists.osdl.org
Errors-To: linux-pm-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

Dave Kleikamp <shaggy@austin.ibm.com> writes:

> I believe it was broken by:
> http://www.kernel.org/git/gitweb.cgi?p=3Dlinux/kernel/git/torvalds/linux-=
2.6.git;a=3Dcommit;h=3D3b4c7d640376dbccfe80fc4f7b8772ecc7de28c5
>
> I have seen this in the -mm tree, but didn't follow up at the time.  I
> was able to fix it with the following patch.  I don't know if it's the
> best fix, but it seems to follow the same logic as the original code.
>
>
> The airo driver used to break out of while loop if there were any signals
> pending.  Since it no longer checks for signals, it at least needs to che=
ck
> if it needs to be frozen.
>
> Signed-off-by: Dave Kleikamp <shaggy@austin.ibm.com>
>
> diff -Nurp linux-2.6.19-rc1/drivers/net/wireless/airo.c linux/drivers/net=
/wireless/airo.c
> --- linux-2.6.19-rc1/drivers/net/wireless/airo.c	2006-10-05 07:22:39.0000=
00000 -0500
> +++ linux/drivers/net/wireless/airo.c	2006-10-07 13:42:13.000000000 -0500
> @@ -3090,7 +3090,8 @@ static int airo_thread(void *data) {
>  						set_bit(JOB_AUTOWEP, &ai->jobs);
>  						break;
>  					}
> -					if (!kthread_should_stop()) {
> +					if (!kthread_should_stop() &&
> +					    !freezing(current)) {
>  						unsigned long wake_at;
>  						if (!ai->expires || !ai->scan_timeout) {
>  							wake_at =3D max(ai->expires,
> @@ -3102,7 +3103,8 @@ static int airo_thread(void *data) {
>  						schedule_timeout(wake_at - jiffies);
>  						continue;
>  					}
> -				} else if (!kthread_should_stop()) {
> +				} else if (!kthread_should_stop() &&
> +					   !freezing(current)) {
>  					schedule();
>  					continue;
>  				}
>

thanks. with this patch applied i can suspend to ram with the airo
module loaded.

--alex--

-- =

| I believe the moment is at hand when, by a paranoiac and active |
|  advance of the mind, it will be possible (simultaneously with  |
|  automatism and other passive states) to systematize confusion  |
|  and thus to help to discredit completely the world of reality. |

From: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
Subject: [PATCH] random: seed random_int_secret at least poorly at core_initcall time
Date: Tue, 12 Nov 2013 14:46:03 +0100
Message-ID: <20131112134603.GE14929@order.stressinduktion.org>
References: <cover.1384160397.git.dborkman@redhat.com> <2ea03f60bb65429cbe5d74a6d356fde3eefcf06c.1384160397.git.dborkman@redhat.com> <20131111134357.GC10104@thunk.org> <20131112000307.GB14929@order.stressinduktion.org> <20131112115350.GA14077@thunk.org> <20131112131627.GD14929@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	shemminger-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, fweimer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20131112131627.GD14929-5j1vdhnGyZutBveJljeh2VPnkB77EeZ12LY78lusg7I@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 12, 2013 at 02:16:27PM +0100, Hannes Frederic Sowa wrote:
> On Tue, Nov 12, 2013 at 06:53:50AM -0500, Theodore Ts'o wrote:
> > > Btw. do you see problems regarding get_random_int on architectures without
> > > hardware offloading?
> > > 
> > > We are initializing random_int_secret really late (after all the init
> > > calls) and I wonder if we should also use a two stage initialization
> > > there, so we have a more unpredictable MD5 hash at early boot.
> > 
> > Most of the users of get_random_int(), at least to date, have been for
> > things like ASLR.  A quick audit shows only one device driver user
> > that might be impacted: drivers/net/wireless/cw1200/wsm.c.
> > 
> > It's not a bad idea to do a two stage init just in case
> > get_random_int() gets used by other code --- although that brings up
> > something that I know is really needed, but which I haven't had time
> > to try to address yet: we really need to document all of the various
> > interfaces that various kernel routines can use to get random numbers,
> > and document what their performance and security characteristics are.
> > We have probably have a lot of code where the authors didn't realize
> > that some other interface would be a better match for their needs, or
> > the code is old enough that predates some of the newer interfaces.
> 
> It is needed by fork to set up the stack canary. And this actually gets
> called before the secret is initialized.

Maybe we could use this for the time being and use the seeding method
of kaslr as soon as it hits the tree?

I didn't bother including arch_get_random_int as we don't use the seed at all
if that function is available on the particular architecture.

[PATCH] random: seed random_int_secret at least poorly at core_initcall time

We don't seed random_int secret until after all the initcalls happend. But
it does get used before that. So try at least to seed it before initial
usage until it gets reseeded again after the initcalls.

Cc: "Theodore Ts'o" <tytso-3s7WtUTddSA@public.gmane.org>
Signed-off-by: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
---
 drivers/char/random.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/char/random.c b/drivers/char/random.c
index 4fe5609..9f2623c 100644
--- a/drivers/char/random.c
+++ b/drivers/char/random.c
@@ -1468,6 +1468,16 @@ int random_int_secret_init(void)
 	return 0;
 }
 
+static int __init random_int_secret_init_early(void)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(random_int_secret); i++)
+		random_int_secret[i] = jiffies ^ random_get_entropy();
+	return 0;
+}
+core_initcall(random_int_secret_init_early);
+
 /*
  * Get a random word for internal kernel use only. Similar to urandom but
  * with the goal of minimal entropy pool depletion. As a result, the random
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

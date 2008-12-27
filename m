From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: RE: unsafe locks seen with netperf on net-2.6.29 tree
Date: Sat, 27 Dec 2008 21:38:28 +0100
Message-ID: <1230410308.9487.295.camel@twins>
References: <9929d2390812250225w19bcd2f7n11357ff26de78c52@mail.gmail.com>
	 <20081225112658.GA7260@gondor.apana.org.au>
	 <1230300535.9487.292.camel@twins>
	 <EA929A9653AAE14F841771FB1DE5A1365F56B6648A@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	Ingo Molnar <mingo@elte.hu>, Eric Dumazet <dada1@cosmosbay.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep11-int.chello.at ([62.179.121.31]:57924 "EHLO
	viefep11-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753965AbYL0UiY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Dec 2008 15:38:24 -0500
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365F56B6648A@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2008-12-27 at 12:38 -0700, Tantilov, Emil S wrote:
> Peter Zijlstra wrote:

> > index 9007ccd..a074d77 100644
> > --- a/include/linux/percpu_counter.h
> > +++ b/include/linux/percpu_counter.h
> > @@ -30,8 +30,16 @@ struct percpu_counter {
> >  #define FBC_BATCH    (NR_CPUS*4)
> >  #endif
> >
> > -int percpu_counter_init(struct percpu_counter *fbc, s64 amount);
> > -int percpu_counter_init_irq(struct percpu_counter *fbc, s64 amount);
> > +int __percpu_counter_init(struct percpu_counter *fbc, s64 amount,
> > +                       struct lock_class_key *key);
> > +
> > +#define percpu_counter_init(fbc, value)                                      \
> > +     do {                                                            \
> > +             static struct lock_class_key __key;                     \
> > +                                                                     \
> > +             __percpu_counter_init(fbc, value, &__key);              \
> > +     } while (0)
> > +
> >  void percpu_counter_destroy(struct percpu_counter *fbc);
> >  void percpu_counter_set(struct percpu_counter *fbc, s64 amount);
> >  void __percpu_counter_add(struct percpu_counter *fbc, s64 amount,

> This patch fails to compile:
> 
> mm/backing-dev.c: In function 'bdi_init':
> mm/backing-dev.c:226: error: expected expression bedore 'do'

Ah indeed, stupid me...

Please try something like this instead of the above hunk:

@@ -30,8 +30,16 @@ struct percpu_counter {
 #define FBC_BATCH      (NR_CPUS*4)
 #endif

-int percpu_counter_init(struct percpu_counter *fbc, s64 amount);
-int percpu_counter_init_irq(struct percpu_counter *fbc, s64 amount);
+int __percpu_counter_init(struct percpu_counter *fbc, s64 amount,
+                         struct lock_class_key *key);
+
+#define percpu_counter_init(fbc, value)                                        \
+       ({                                                              \
+               static struct lock_class_key __key;                     \
+                                                                       \
+               __percpu_counter_init(fbc, value, &__key);              \
+       })
+
 void percpu_counter_destroy(struct percpu_counter *fbc);
 void percpu_counter_set(struct percpu_counter *fbc, s64 amount);
 void __percpu_counter_add(struct percpu_counter *fbc, s64 amount, s32 batch)


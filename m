From: Samir Bellabes <sam@synack.fr>
Subject: Re: [RFC 4/9] snet: introduce snet_core.c and snet.h
Date: Wed, 06 Jan 2010 20:46:35 +0100
Message-ID: <m2y6kbm2xw.fsf@ssh.synack.fr>
References: <1262437456-24476-1-git-send-email-sam@synack.fr>
	<1262437456-24476-5-git-send-email-sam@synack.fr>
	<4B41FE9D.2070708@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B41FE9D.2070708@trash.net> (Patrick McHardy's message of "Mon,
	04 Jan 2010 15:43:41 +0100")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> writes:

>> +struct snet_event {
>> +	enum snet_syscall syscall;
>> +	u8 protocol;
>> +} __attribute__ ((packed));
>
> Does this really need to be packed? You're using it in a
> struct snet_event_entry, which is padded anyways.

I think that that members needs to be aligned, because this struct is
used for the jhash() computation.
when testing on x86_64, I discovered that jhash value wasn't the same,
for a same struct snet_event. Then I thougth about misaligned data, and
possible 'hole' between syscall and protocol.

anyway, I patched the code to use jhash_2words() or jhash_1word().
here is a patch, which apply on top of initial serie

thank you Patrick,
sam

commit bacdb6b62549b58370298f89f908d66c5a3cab66
Author: Samir Bellabes <sam@synack.fr>
Date:   Wed Jan 6 20:36:06 2010 +0100

    snet : delete attribute packed for snet_event and use proper jash functions
    
    the structure snet_event was using the attribute packed, which seems to be
    unnecessary.
    this patch also fix the good compute of hashes, by moving jash() to
    jash_1word() and jash_2words()
    
    Noticed by Patrick McHardy <kaber@trash.net>
    
    Signed-off-by: Samir Bellabes <sam@synack.fr>

diff --git a/security/snet/include/snet.h b/security/snet/include/snet.h
index 47da614..75b32d5 100644
--- a/security/snet/include/snet.h
+++ b/security/snet/include/snet.h
@@ -9,6 +9,6 @@
 struct snet_event {
 	enum snet_syscall syscall;
 	u8 protocol;
-} __attribute__ ((packed));
+};
 
 #endif /* _SNET_H */
diff --git a/security/snet/snet_event.c b/security/snet/snet_event.c
index 9f0b0f3..cc3b6a2 100644
--- a/security/snet/snet_event.c
+++ b/security/snet/snet_event.c
@@ -24,17 +24,12 @@ static struct snet_event_entry *__snet_event_lookup(const enum snet_syscall sysc
 	unsigned int h = 0;
 	struct list_head *l;
 	struct snet_event_entry *s;
-	struct snet_event t;
 
 	if (!snet_evh)
 		return NULL;
 
-	/* building the element to look for */
-	t.syscall = syscall;
-	t.protocol = protocol;
-
 	/* computing its hash value */
-	h = jhash(&t, sizeof(struct snet_event), 0) % snet_evh_size;
+	h = jhash_2words(syscall, protocol, 0) % snet_evh_size;
 	l = &snet_evh[h];
 
 	list_for_each_entry(s, l, list) {
@@ -127,7 +122,7 @@ int snet_event_insert(const enum snet_syscall syscall, const u8 protocol)
 	data->se.syscall = syscall;
 	data->se.protocol = protocol;
 	INIT_LIST_HEAD(&(data->list));
-	h = jhash(&(data->se), sizeof(struct snet_event), 0) % snet_evh_size;
+	h = jhash_2words(data->se.syscall, data->se.protocol, 0) % snet_evh_size;
 	list_add_tail(&data->list, &snet_evh[h]);
 	write_unlock_bh(&snet_evh_lock);
 	pr_debug("[%u]=(syscall=%s, protocol=%u)\n",
diff --git a/security/snet/snet_verdict.c b/security/snet/snet_verdict.c
index 0cad06b..477af3b 100644
--- a/security/snet/snet_verdict.c
+++ b/security/snet/snet_verdict.c
@@ -29,18 +29,16 @@ static struct snet_verdict_entry *__snet_verdict_lookup(const u32 verdict_id)
 	unsigned int h = 0;
 	struct list_head *l = NULL;
 	struct snet_verdict_entry *s = NULL;
-	u32 vid = 0;
 
 	if (!snet_vdh)
 		return NULL;
 
-	vid = verdict_id;
 	/* computing its hash value */
-	h = jhash(&vid, sizeof(u32), 0) % snet_vdh_size;
+	h = jhash_1word(verdict_id, 0) % snet_vdh_size;
 	l = &snet_vdh[h];
 
 	list_for_each_entry(s, l, list) {
-		if (s->verdict_id == vid) {
+		if (s->verdict_id == verdict_id) {
 			return s;
 		}
 	}
@@ -134,7 +132,7 @@ int snet_verdict_insert(void)
 	data->verdict_id = verdict_id;
 	data->verdict = SNET_VERDICT_PENDING;
 	INIT_LIST_HEAD(&(data->list));
-	h = jhash(&(data->verdict_id), sizeof(u32), 0) % snet_vdh_size;
+	h = jhash_1word(data->verdict_id, 0) % snet_vdh_size;
 
 	write_lock_bh(&snet_vdh_lock);
 	if (snet_vdh) {

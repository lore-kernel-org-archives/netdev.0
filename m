From: Joe Perches <joe@perches.com>
Subject: Re: [RFC PATCH] vsnprintf: Remove use of %n and convert existing
 uses
Date: Thu, 12 Sep 2013 08:59:22 -0700
Message-ID: <1379001562.2075.9.camel@joe-AO722>
References: <1378926562.4714.11.camel@joe-AO722>
	 <CAGXu5jLO6109fkejXqX=WhkQnfAUeWtTcow0v1BNqyi=8=Qa3Q@mail.gmail.com>
	 <1378928700.4714.17.camel@joe-AO722>
	 <CAGXu5jLTjrPr=GwOmMcu55Qp9K-_XS75xq9NJ0vBUEwy-i_YMw@mail.gmail.com>
	 <1378941761.4714.37.camel@joe-AO722>
	 <201309120840.HHE37542.OJMFFHSOQOtVFL@I-love.SAKURA.ne.jp>
	 <1378944257.4714.45.camel@joe-AO722>
	 <20130912001911.GO13318@ZenIV.linux.org.uk>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B732A@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Al Viro <viro@ZenIV.linux.org.uk>,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com,
	keescook@chromium.org, fweisbec@gmail.com,
	dan.carpenter@oracle.com, devel@driverdev.osuosl.org,
	gregkh@linuxfoundation.org, tushar.behera@linaro.org,
	lidza.louina@gmail.com, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	courmisch@gmail.com, vyasevich@gmail.com, nhorman@tuxdriver.com,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B732A@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-09-12 at 09:06 +0100, David Laight wrote:
> > On Wed, Sep 11, 2013 at 05:04:17PM -0700, Joe Perches wrote:
> > > On Thu, 2013-09-12 at 08:40 +0900, Tetsuo Handa wrote:
> > > > Joe Perches wrote:
> > > > > -	seq_printf(m, "%s%d%n", con->name, con->index, &len);
> > > > > +	len = seq_printf(m, "%s%d", con->name, con->index);
> > > >
> > > > Isn't len always 0 or -1 ?
> > >
> > > Right.  Well you're no fun...
[]
> > > Suggestions?
> 
> Change the return type of seq_printf() to void and require that
> code use access functions/macros to find the length and error
> status. Possibly save the length of the last call separately.

Are there any races if this is done?
---
 fs/seq_file.c            | 15 +++++++--------
 include/linux/seq_file.h |  6 ++++--
 2 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/fs/seq_file.c b/fs/seq_file.c
index 3135c25..b6c9eab 100644
--- a/fs/seq_file.c
+++ b/fs/seq_file.c
@@ -389,32 +389,31 @@ int seq_escape(struct seq_file *m, const char *s, const char *esc)
 }
 EXPORT_SYMBOL(seq_escape);
 
-int seq_vprintf(struct seq_file *m, const char *f, va_list args)
+void seq_vprintf(struct seq_file *m, const char *f, va_list args)
 {
 	int len;
 
 	if (m->count < m->size) {
 		len = vsnprintf(m->buf + m->count, m->size - m->count, f, args);
+		m->last_len = len;
 		if (m->count + len < m->size) {
 			m->count += len;
-			return 0;
+			m->last_rtn = 0;
+			return;
 		}
 	}
 	seq_set_overflow(m);
-	return -1;
+	m->last_rtn = -1;
 }
 EXPORT_SYMBOL(seq_vprintf);
 
-int seq_printf(struct seq_file *m, const char *f, ...)
+void seq_printf(struct seq_file *m, const char *f, ...)
 {
-	int ret;
 	va_list args;
 
 	va_start(args, f);
-	ret = seq_vprintf(m, f, args);
+	seq_vprintf(m, f, args);
 	va_end(args);
-
-	return ret;
 }
 EXPORT_SYMBOL(seq_printf);
 
diff --git a/include/linux/seq_file.h b/include/linux/seq_file.h
index 4e32edc..9af05e1 100644
--- a/include/linux/seq_file.h
+++ b/include/linux/seq_file.h
@@ -20,6 +20,8 @@ struct seq_file {
 	size_t size;
 	size_t from;
 	size_t count;
+	size_t last_len;
+	int last_rtn;
 	loff_t index;
 	loff_t read_pos;
 	u64 version;
@@ -89,8 +91,8 @@ int seq_putc(struct seq_file *m, char c);
 int seq_puts(struct seq_file *m, const char *s);
 int seq_write(struct seq_file *seq, const void *data, size_t len);
 
-__printf(2, 3) int seq_printf(struct seq_file *, const char *, ...);
-__printf(2, 0) int seq_vprintf(struct seq_file *, const char *, va_list args);
+__printf(2, 3) void seq_printf(struct seq_file *, const char *, ...);
+__printf(2, 0) void seq_vprintf(struct seq_file *, const char *, va_list args);
 
 int seq_path(struct seq_file *, const struct path *, const char *);
 int seq_dentry(struct seq_file *, struct dentry *, const char *);

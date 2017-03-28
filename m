From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v1] tracing/kprobes: expose maxactive for kretprobe in
 kprobe_events
Date: Tue, 28 Mar 2017 11:34:07 -0400
Message-ID: <20170328113407.56926eec@gandalf.local.home>
References: <1490709142-8856-1-git-send-email-alban@kinvolk.io>
        <20170329002335.1d1fcc491765b632f470f99b@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alban Crequy <alban.crequy@gmail.com>,
        Alban Crequy <alban@kinvolk.io>,
        Alexei Starovoitov <ast@kernel.org>,
        Jonathan Corbet <corbet@lwn.net>,
        Ingo Molnar <mingo@redhat.com>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Omar Sandoval <osandov@fb.com>, linux-doc@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        iago@kinvolk.io, michael@kinvolk.io,
        "Dorau, Lukasz" <lukasz.dorau@intel.com>
To: Masami Hiramatsu <mhiramat@kernel.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20170329002335.1d1fcc491765b632f470f99b@kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 29 Mar 2017 00:23:35 +0900
Masami Hiramatsu <mhiramat@kernel.org> wrote:

> > @@ -598,8 +601,10 @@ static int create_trace_kprobe(int argc, char **argv)
> >  {
> >  	/*
> >  	 * Argument syntax:
> > -	 *  - Add kprobe: p[:[GRP/]EVENT] [MOD:]KSYM[+OFFS]|KADDR [FETCHARGS]
> > -	 *  - Add kretprobe: r[:[GRP/]EVENT] [MOD:]KSYM[+0] [FETCHARGS]
> > +	 *  - Add kprobe:
> > +	 *      p[:[GRP/]EVENT] [MOD:]KSYM[+OFFS]|KADDR [FETCHARGS]
> > +	 *  - Add kretprobe:
> > +	 *      r[MAXACTIVE][:[GRP/]EVENT] [MOD:]KSYM[+0] [FETCHARGS]
> >  	 * Fetch args:
> >  	 *  $retval	: fetch return value
> >  	 *  $stack	: fetch stack address
> > @@ -619,6 +624,7 @@ static int create_trace_kprobe(int argc, char **argv)
> >  	int i, ret = 0;
> >  	bool is_return = false, is_delete = false;
> >  	char *symbol = NULL, *event = NULL, *group = NULL;
> > +	int maxactive = 0;
> >  	char *arg;
> >  	unsigned long offset = 0;
> >  	void *addr = NULL;
> > @@ -637,8 +643,26 @@ static int create_trace_kprobe(int argc, char **argv)
> >  		return -EINVAL;
> >  	}
> >  
> > -	if (argv[0][1] == ':') {
> > +	if (is_return && isdigit(argv[0][1]) && strchr(&argv[0][1], ':')) {  
> 
> This only supports r[MAXACTIVE:[GRP/]EVENT]. e.g "r100" without event name.

You mean it doesn't support adding MAXACTIVE without the ':event'.

> 
> Thank you,
> 
> > +		event = strchr(&argv[0][1], ':') + 1;
> > +		event[-1] = '\0';
> > +		ret = kstrtouint(&argv[0][1], 0, &maxactive);
> > +		if (ret) {
> > +			pr_info("Failed to parse maxactive.\n");
> > +			return ret;
> > +		}
> > +		/* kretprobes instances are iterated over via a list. The
> > +		 * maximum should stay reasonable.
> > +		 */
> > +		if (maxactive > 1024) {

Also, can we get rid of magic numbers within the code. There should be a
const or macro defined as MAX_MAXACTIVE or something, and use that here.

-- Steve


> > +			pr_info("Maxactive is too big.\n");
> > +			return -EINVAL;
> > +		}
> > +	} else if (argv[0][1] == ':') {
> >  		event = &argv[0][2];
> > +	}
> > +
> > +	if (event) {
> >  		if (strchr(event, '/')) {
> >  			group = event;
> >  			event = strchr(group, '/') + 1;
> > @@ -718,8 +742,8 @@ static int create_trace_kprobe(int argc, char **argv)
> >  				 is_return ? 'r' : 'p', addr);
> >  		event = buf;
> >  	}
> > -	tk = alloc_trace_kprobe(group, event, addr, symbol, offset, argc,
> > -			       is_return);
> > +	tk = alloc_trace_kprobe(group, event, addr, symbol, offset, maxactive,
> > +			       argc, is_return);
> >  	if (IS_ERR(tk)) {
> >  		pr_info("Failed to allocate trace_probe.(%d)\n",
> >  			(int)PTR_ERR(tk));
> > -- 
> > 2.7.4
> >   
> 
> 


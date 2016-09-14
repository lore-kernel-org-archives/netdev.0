From: Marcelo <marcelo.leitner@gmail.com>
Subject: Re: [RFC PATCH v3 2/7] proc: Reduce cache miss in
 {snmp,netstat}_seq_show
Date: Wed, 14 Sep 2016 08:55:43 -0300
Message-ID: <20160914115543.GF17689@localhost.localdomain>
References: <1473402842-1987-1-git-send-email-hejianet@gmail.com>
 <1473402842-1987-3-git-send-email-hejianet@gmail.com>
 <20160912185752.GB17689@localhost.localdomain>
 <22d87ec3-608f-fe41-5eb7-fe1104f133dd@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        linux-kernel@vger.kernel.org, davem@davemloft.net,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>
To: hejianet <hejianet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <22d87ec3-608f-fe41-5eb7-fe1104f133dd@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jia,

On Wed, Sep 14, 2016 at 01:58:42PM +0800, hejianet wrote:
> Hi Marcelo
> 
> 
> On 9/13/16 2:57 AM, Marcelo wrote:
> > On Fri, Sep 09, 2016 at 02:33:57PM +0800, Jia He wrote:
> > > This is to use the generic interface snmp_get_cpu_field{,64}_batch to
> > > aggregate the data by going through all the items of each cpu sequentially.
> > > Then snmp_seq_show and netstat_seq_show are split into 2 parts to avoid build
> > > warning "the frame size" larger than 1024 on s390.
> > Yeah about that, did you test it with stack overflow detection?
> > These arrays can be quite large.
> > 
> > One more below..
> Do you think it is acceptable if the stack usage is a little larger than 1024?
> e.g. 1120
> I can't find any other way to reduce the stack usage except use "static" before
> unsigned long buff[TCP_MIB_MAX]
> 
> PS. sizeof buff is about TCP_MIB_MAX(116)*8=928
> B.R.

That's pretty much the question. Linux has the option on some archs to
run with 4Kb (4KSTACKS option), so this function alone would be using
25% of it in this last case. While on x86_64, it uses 16Kb (6538b8ea886e
("x86_64: expand kernel stack to 16K")).

Adding static to it is not an option as it actually makes the variable
shared amongst the CPUs (and then you have concurrency issues), plus the
fact that it's always allocated, even while not in use.

Others here certainly know better than me if it's okay to make such
usage of the stach.

> > > +static int netstat_seq_show_ipext(struct seq_file *seq, void *v)
> > > +{
> > > +	int i;
> > > +	u64 buff64[IPSTATS_MIB_MAX];
> > > +	struct net *net = seq->private;
> > >   	seq_puts(seq, "\nIpExt:");
> > >   	for (i = 0; snmp4_ipextstats_list[i].name != NULL; i++)
> > >   		seq_printf(seq, " %s", snmp4_ipextstats_list[i].name);
> > >   	seq_puts(seq, "\nIpExt:");
> > You're missing a memset() call here.

Not sure if you missed this one or not..

Thanks,
Marcelo

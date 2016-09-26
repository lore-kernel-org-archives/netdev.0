From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH v3] net: ip, diag -- Add diag interface for raw sockets
Date: Tue, 27 Sep 2016 01:38:28 +0300
Message-ID: <20160926223828.GL1876@uranus.lan>
References: <999f0ddb-82e4-ea07-b52a-59d08bc7816d@cumulusnetworks.com>
 <20160916070623.GD1867@uranus.lan>
 <20160916190000.GA18116@uranus.lan>
 <59e12627-7043-fd20-0d68-899ab43b0e71@cumulusnetworks.com>
 <20160916193927.GB18116@uranus.lan>
 <d943c6b7-0f06-3823-58d2-6f79f17c3d59@cumulusnetworks.com>
 <20160916195252.GC18116@uranus.lan>
 <6464ac16-a15b-384e-ffb1-3ee84cdce313@cumulusnetworks.com>
 <20160916200722.GA26044@uranus.lan>
 <20160920211343.GI26044@uranus.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        avagin@openvz.org, stephen@networkplumber.org
To: David Ahern <dsa@cumulusnetworks.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160920211343.GI26044@uranus.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 21, 2016 at 12:13:43AM +0300, Cyrill Gorcunov wrote:
> On Fri, Sep 16, 2016 at 11:07:22PM +0300, Cyrill Gorcunov wrote:
> > > It may well be a ss bug / problem. As I mentioned I am always seeing 255 for the protocol which
> > 
> > It is rather not addressed in ss. I mean, look, when we send out a diag packet
> > the kernel look ups for a handler, which for raw protocol we register as
> > 
> > static const struct inet_diag_handler raw_diag_handler = {
> > 	.dump= raw_diag_dump,
> > 	.dump_one= raw_diag_dump_one,
> > 	.idiag_get_info= raw_diag_get_info,
> > 	.idiag_type= IPPROTO_RAW,
> > 	.idiag_info_size= 0,
> > #ifdef CONFIG_INET_DIAG_DESTROY
> > 	.destroy= raw_diag_destroy,
> > #endif
> > };
> > 
> > so if we patch ss and ask for IPPROTO_ICMP in netlink packet the
> > kernel simply won't find anything. Thus I think we need (well, I need)
> > to extend the patch and register IPPROTO_ICMP diag type, then
> > extend ss as well. (If only I didn't miss somethin obvious).
> > 
> > > is odd since ss does a dump and takes the matches and invokes the kill.
> > > Thanks for taking the time to do the kill piece.
> 
> Sorry for delay in reply (I got flu unexpectedly). You know, it eventually
> become uneasy to implement handling for sock-raw because they are special.
> They described as ipproto-ip in net/ipv4/af_inet.c, so it matches any
> protocol specified with the socket call. In turn inet-diag module handled
> predefined protocols only, in particular IPPROTO_RAW in our case. Thus
> to fecth some real protocol sitting in raw sockets hashes we need some
> kind of additional argument passed in the request. I guess we may
> use @idiag_ext field for this sake? Or require @idiag_ext to have
> INET_DIAG_PROTOCOL bit set and then fetch real protocol from
> additional attribute? Sounds ok?

Something like

Index: linux-ml.git/include/uapi/linux/inet_diag.h
===================================================================
--- linux-ml.git.orig/include/uapi/linux/inet_diag.h    2016-09-11 20:56:18.191584145 +0300
+++ linux-ml.git/include/uapi/linux/inet_diag.h 2016-09-27 01:34:08.413172394 +0300
@@ -38,7 +38,7 @@ struct inet_diag_req_v2 {
        __u8    sdiag_family;
        __u8    sdiag_protocol;
        __u8    idiag_ext;
-       __u8    pad;
+       __u8    sdiag_raw_protocol;     /* SOCK_RAW only, @pad for others */
        __u32   idiag_states;
        struct inet_diag_sockid id;
 };

and in raw-diag module we will use @sdiag_raw_protocol instead of
@sdiag_protocol field. Didn't cover ss tool source code yet but
I think the idea is seen. Still not sure if start using @pad here
is a good idea (it's uapi), maybe beter to ask nla attribute which would
come right afterh the inet_diag_req_v2 message?

	Cyrill

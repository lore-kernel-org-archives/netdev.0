From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] meta ematch
Date: Sun, 16 Jan 2005 17:49:05 +0100
Message-ID: <20050116164905.GX26856@postel.suug.ch>
References: <20050113174111.GP26856@postel.suug.ch> <41E6C3E5.2020908@trash.net> <20050113192047.GQ26856@postel.suug.ch> <41E71CC4.3020102@trash.net> <20050114151407.GR26856@postel.suug.ch> <1105887519.1097.597.camel@jzny.localdomain> <20050116150914.GU26856@postel.suug.ch> <1105889874.1090.613.camel@jzny.localdomain> <20050116155758.GV26856@postel.suug.ch> <1105892360.1091.655.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1105892360.1091.655.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1105892360.1091.655.camel@jzny.localdomain> 2005-01-16 11:19
> > > I am not sure iam following yet:
> > > 
> > > So in the case of indev, you would need to 
> > > - get indev ifindex from skb
> > > - get indev name from skb
> > > - compare the two??
> > >
> 
> Can you explain the above in context of indev = "eth0"? I am still not
> sure i get it:
> 
> +     if (meta_get(skb, info, &meta->lvalue, &l_value) < 0 ||
> +         meta_get(skb, info, &meta->rvalue, &r_value) < 0)
> +             return 0;
> +     r = meta_type_ops(&meta->lvalue)->compare(&l_value, &r_value);

Sure, indev = "eth0"

TCA_EM_META_HDR = {
	.left = {
		.kind = TCF_META_TYPE_VAR << 12 | TCF_META_ID_INDEV,
		.op = TCF_EM_EQ,
	},
	.right = {
		.kind = TCF_META_TYPE_VAR << 12 | TCF_META_ID_VALUE,
	},
};

TCA_EM_META_LVALUE = EMPTY; /* unused */
TCA_EM_META_RVALUE = "eth0"

The configuration part will transform this into:

struct meta_match = {
	.lvalue = {
		.hdr = {
			.kind = TCF_META_TYPE_VAR << 12 | TCF_META_ID_INDEV,
			.op = TCF_EM_EQ,
		},
	},
	.rvalue = {
		.hdr = {
			.kind = TCF_META_TYPE_VAR << 12 | TCF_META_ID_VALUE,
		}
		.val = strdup("eth0"),
		.len = strlen("eth0"),
	},
}

meta_get will make meta_obj's out of it:

struct meta_obj l_value = {
	.value = dev->name,
	.len = strlen(dev->name),
},

struct meta_obj r_value = {
	.value = "eth0",
	.len = strlen("eth0"),
}

the type specific compare will compare these.

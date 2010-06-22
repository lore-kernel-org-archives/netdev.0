From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [ethtool PATCH] ethtool: Support n-tuple filter programming
Date: Mon, 21 Jun 2010 23:42:12 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.64.1006212340240.5928@PPWASKIE-MOBL2.amr.corp.intel.com>
References: <20100204075101.16661.95658.stgit@localhost.localdomain>
 <1277150272.2100.47.camel@achroite.uk.solarflarecom.com>
 <Pine.WNT.4.64.1006211326380.4956@PPWASKIE-MOBL2.amr.corp.intel.com>
 <55D68E60-BAFB-4000-81E2-20913CC326C9@earthlink.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Mitchell Erblich <erblichs@earthlink.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:9706 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751815Ab0FVGmO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jun 2010 02:42:14 -0400
In-Reply-To: <55D68E60-BAFB-4000-81E2-20913CC326C9@earthlink.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 21 Jun 2010, Mitchell Erblich wrote:

>
> On Jun 21, 2010, at 1:31 PM, Peter P Waskiewicz Jr wrote:
>
>> On Mon, 21 Jun 2010, Ben Hutchings wrote:
>>
>>> On Wed, 2010-02-03 at 23:51 -0800, Jeff Kirsher wrote:
>>>> From: Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>
>>>>
>>>> Program underlying ethernet devices with n-tuple flow classification
>>>> filters.
>>>>
>>>> This also adds a new flag to ethtool_flags, allowing n-tuple
>>>> programming to be toggled using the set_flags call.
>>>
>>> I just noticed a problem with the implementation which makes me wonder
>>> whether this was tested at all:
>>
>> Yes, it was tested.  We didn't hit every corner case, which I think your catch below is a corner case issue.  Our hardware can only do so much.
>>
>>>
>>> [...]
>>>> +static struct cmdline_info cmdline_ntuple[] = {
>>>> +	{ "src-ip", CMDL_INT, &ntuple_fs.h_u.tcp_ip4_spec.ip4src, NULL },
>>>> +	{ "src-ip-mask", CMDL_UINT, &ntuple_fs.m_u.tcp_ip4_spec.ip4src, NULL },
>>>> +	{ "dst-ip", CMDL_INT, &ntuple_fs.h_u.tcp_ip4_spec.ip4dst, NULL },
>>>> +	{ "dst-ip-mask", CMDL_UINT, &ntuple_fs.m_u.tcp_ip4_spec.ip4dst, NULL },
>>>> +	{ "src-port", CMDL_INT, &ntuple_fs.h_u.tcp_ip4_spec.psrc, NULL },
>>>> +	{ "src-port-mask", CMDL_UINT, &ntuple_fs.m_u.tcp_ip4_spec.psrc, NULL },
>>>> +	{ "dst-port", CMDL_INT, &ntuple_fs.h_u.tcp_ip4_spec.pdst, NULL },
>>>> +	{ "dst-port-mask", CMDL_UINT, &ntuple_fs.m_u.tcp_ip4_spec.pdst, NULL },
>>>> +	{ "vlan", CMDL_INT, &ntuple_fs.vlan_tag, NULL },
>>>> +	{ "vlan-mask", CMDL_UINT, &ntuple_fs.vlan_tag_mask, NULL },
>>>> +	{ "user-def", CMDL_INT, &ntuple_fs.data, NULL },
>>>> +	{ "user-def-mask", CMDL_UINT, &ntuple_fs.data_mask, NULL },
>>>> +	{ "action", CMDL_INT, &ntuple_fs.action, NULL },
>>>> +};
>>> [...]
>>>> +                       if (mode == MODE_SNTUPLE) {
>>>> +                               if (!strcmp(argp[i], "flow-type")) {
>>>> +                                       i += 1;
>
> 			Why not " i++;  " ?

I used previous style in the file.  Either is fine.  However, please note 
this code has already been committed and released.  If we want to change 
this, then a new patch should be submitted.  I don't think it's worth the 
thrash though.

>
>>>> +                                       if (i >= argc) {
>>>> +                                               show_usage(1);
>>>> +                                               break;
>>>> +                                       }
>>>> +                                       ntuple_fs.flow_type =
>>>> +                                                   rxflow_str_to_type(argp[i]);
>>>> +                                       i += 1;
>
> 			Why not "  i++;  " ?

See above.

>
>>>> +                                       parse_generic_cmdline(argc, argp, i,
>>>> +                                               &sntuple_changed,
>>>> +                                               cmdline_ntuple,
>>>> +                                               ARRAY_SIZE(cmdline_ntuple));
>>>> +                                       i = argc;
>>>> +                                       break;
>>>> +                               } else {
>>>> +                                       show_usage(1);
>>>> +                               }
>>>> +                               break;
>>>> +                       }
>>> [...]
>>>
>>> parse_generic_cmdline() will write an int for each argument defined with
>>> type CMDL_INT or CMDL_UINT.  But the fields in ntuple_fs are not all of
>>> type int (or even 32-bit) - some of them are 16-bit or 64-bit, and some
>>> of them are big-endian.  I also wonder whether anyone really wants to
>>> enter an IPv4 address as a single integer.
>>
>> The assignment is broken since 'p' is an int.  That can be fixed.  Also, we can fix the 64-bit field.  I added the user-defined field to be 64-bit so that we weren't locking anyone down.  My hardware only uses 2 bytes, so I was only able to test that.
>>
>> When this was proposed, we added the IPv4 address as a single int.  People seemed ok with it at the time, so we went with it.  If you have a different approach, please present it.
>>
>> Cheers,
>> -PJ
>
> Without changing the flow:
>
> 		NIT cleanup.
> 		See inline.
>
> 		Mitchell Erblich
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>

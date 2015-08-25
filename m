From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [PATCHv5 net-next 10/10] openvswitch: Allow attaching helpers to
 ct action
Date: Tue, 25 Aug 2015 13:10:00 -0700
Message-ID: <CANr6G5xTdckxEqMpfGedm=tmBiRDO0kGNu7wuRDG_2hXZnPx1Q@mail.gmail.com>
References: <1440462740-23358-1-git-send-email-joestringer@nicira.com>
 <1440462740-23358-11-git-send-email-joestringer@nicira.com> <20150825183302.GN3707@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Pravin Shelar <pshelar@nicira.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fwestpha@redhat.com>,
	Hannes Sowa <hannes@redhat.com>,
	Justin Pettit <jpettit@nicira.com>,
	Jesse Gross <jesse@nicira.com>, netfilter-devel@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150825183302.GN3707@pox.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 25 August 2015 at 11:33, Thomas Graf <tgraf@suug.ch> wrote:
> On 08/24/15 at 05:32pm, Joe Stringer wrote:
>> Add support for using conntrack helpers to assist protocol detection.
>> The new OVS_CT_ATTR_HELPER attribute of the CT action specifies a helper
>> to be used for this connection. If no helper is specified, then helpers
>> will be automatically applied as per the sysctl configuration of
>> net.netfilter.nf_conntrack_helper.
>>
>> The helper may be specified as part of the conntrack action, eg:
>> ct(helper=ftp). Initial packets for related connections should be
>> committed to allow later packets for the flow to be considered
>> established.
>>
>> Example ovs-ofctl flows allowing FTP connections from ports 1->2:
>> in_port=1,tcp,action=ct(helper=ftp,commit),2
>> in_port=2,tcp,ct_state=-trk,action=ct(recirc)
>> in_port=2,tcp,ct_state=+trk-new+est,action=1
>> in_port=2,tcp,ct_state=+trk+rel,action=1
>
> Not subject to this patch but we may want to revisit the syntax of the
> state flags. It's neatly compressed like this but ct_state=untracked
> ct_state=related might be more readable. The +trk should be implicit
> for anything !untracked

Fair criticism. My thoughts were that this was a reasonable
middleground between representing masked flags like
"ct_state=0xc2/0xc3" vs. having overly verbose state descriptions like
the corresponding "ct_state=tracked,!new,established,reply_direction".
Either way, we need to represent the three possible states for each
flag: set and we care about the value, unset and we care about the
value, or we don't care about the value. Arguably the example above is
a bit imprecise, because the +trk flows intersect. Omitting the "+trk"
would make all of the return flows intersect.

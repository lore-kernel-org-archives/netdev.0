From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH V2 3/4] net-next: dsa: fix flow dissection
Date: Mon, 24 Jul 2017 04:26:43 +0800
Message-ID: <201707240442.Bnz5c2Ld%fengguang.wu@intel.com>
References: <20170721085813.30789-3-john@phrozen.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="ReaqsoxgOBHFXBhH"
Cc: kbuild-all@01.org, Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, John Crispin <john@phrozen.org>
To: John Crispin <john@phrozen.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170721085813.30789-3-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--ReaqsoxgOBHFXBhH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi John,

[auto build test ERROR on net-next/master]
[also build test ERROR on v4.13-rc1 next-20170721]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/John-Crispin/net-next-dsa-move-struct-dsa_device_ops-to-the-global-header-file/20170724-034620
config: i386-randconfig-a0-07231650 (attached as .config)
compiler: gcc-5 (Debian 5.4.1-2) 5.4.1 20160904
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386 

All errors (new ones prefixed by >>):

   net/core/flow_dissector.c: In function '__skb_flow_dissect':
>> net/core/flow_dissector.c:449:18: error: 'struct net_device' has no member named 'dsa_ptr'
       ops = skb->dev->dsa_ptr->tag_ops;
                     ^

vim +449 net/core/flow_dissector.c

   404	
   405	/**
   406	 * __skb_flow_dissect - extract the flow_keys struct and return it
   407	 * @skb: sk_buff to extract the flow from, can be NULL if the rest are specified
   408	 * @flow_dissector: list of keys to dissect
   409	 * @target_container: target structure to put dissected values into
   410	 * @data: raw buffer pointer to the packet, if NULL use skb->data
   411	 * @proto: protocol for which to get the flow, if @data is NULL use skb->protocol
   412	 * @nhoff: network header offset, if @data is NULL use skb_network_offset(skb)
   413	 * @hlen: packet header length, if @data is NULL use skb_headlen(skb)
   414	 *
   415	 * The function will try to retrieve individual keys into target specified
   416	 * by flow_dissector from either the skbuff or a raw buffer specified by the
   417	 * rest parameters.
   418	 *
   419	 * Caller must take care of zeroing target container memory.
   420	 */
   421	bool __skb_flow_dissect(const struct sk_buff *skb,
   422				struct flow_dissector *flow_dissector,
   423				void *target_container,
   424				void *data, __be16 proto, int nhoff, int hlen,
   425				unsigned int flags)
   426	{
   427		struct flow_dissector_key_control *key_control;
   428		struct flow_dissector_key_basic *key_basic;
   429		struct flow_dissector_key_addrs *key_addrs;
   430		struct flow_dissector_key_ports *key_ports;
   431		struct flow_dissector_key_icmp *key_icmp;
   432		struct flow_dissector_key_tags *key_tags;
   433		struct flow_dissector_key_vlan *key_vlan;
   434		bool skip_vlan = false;
   435		u8 ip_proto = 0;
   436		bool ret;
   437	
   438		if (!data) {
   439			data = skb->data;
   440			proto = skb_vlan_tag_present(skb) ?
   441				 skb->vlan_proto : skb->protocol;
   442			nhoff = skb_network_offset(skb);
   443			hlen = skb_headlen(skb);
   444	
   445			if (unlikely(netdev_uses_dsa(skb->dev))) {
   446				const struct dsa_device_ops *ops;
   447				u8 *p = (u8 *)data;
   448	
 > 449				ops = skb->dev->dsa_ptr->tag_ops;
   450				if (ops->hash_proto_off)
   451					proto = (u16)p[ops->hash_proto_off];
   452				hlen -= ops->hash_nh_off;
   453				nhoff += ops->hash_nh_off;
   454			}
   455		}
   456	
   457		/* It is ensured by skb_flow_dissector_init() that control key will
   458		 * be always present.
   459		 */
   460		key_control = skb_flow_dissector_target(flow_dissector,
   461							FLOW_DISSECTOR_KEY_CONTROL,
   462							target_container);
   463	
   464		/* It is ensured by skb_flow_dissector_init() that basic key will
   465		 * be always present.
   466		 */
   467		key_basic = skb_flow_dissector_target(flow_dissector,
   468						      FLOW_DISSECTOR_KEY_BASIC,
   469						      target_container);
   470	
   471		if (dissector_uses_key(flow_dissector,
   472				       FLOW_DISSECTOR_KEY_ETH_ADDRS)) {
   473			struct ethhdr *eth = eth_hdr(skb);
   474			struct flow_dissector_key_eth_addrs *key_eth_addrs;
   475	
   476			key_eth_addrs = skb_flow_dissector_target(flow_dissector,
   477								  FLOW_DISSECTOR_KEY_ETH_ADDRS,
   478								  target_container);
   479			memcpy(key_eth_addrs, &eth->h_dest, sizeof(*key_eth_addrs));
   480		}
   481	
   482	proto_again:
   483		switch (proto) {
   484		case htons(ETH_P_IP): {
   485			const struct iphdr *iph;
   486			struct iphdr _iph;
   487	ip:
   488			iph = __skb_header_pointer(skb, nhoff, sizeof(_iph), data, hlen, &_iph);
   489			if (!iph || iph->ihl < 5)
   490				goto out_bad;
   491			nhoff += iph->ihl * 4;
   492	
   493			ip_proto = iph->protocol;
   494	
   495			if (dissector_uses_key(flow_dissector,
   496					       FLOW_DISSECTOR_KEY_IPV4_ADDRS)) {
   497				key_addrs = skb_flow_dissector_target(flow_dissector,
   498								      FLOW_DISSECTOR_KEY_IPV4_ADDRS,
   499								      target_container);
   500	
   501				memcpy(&key_addrs->v4addrs, &iph->saddr,
   502				       sizeof(key_addrs->v4addrs));
   503				key_control->addr_type = FLOW_DISSECTOR_KEY_IPV4_ADDRS;
   504			}
   505	
   506			if (ip_is_fragment(iph)) {
   507				key_control->flags |= FLOW_DIS_IS_FRAGMENT;
   508	
   509				if (iph->frag_off & htons(IP_OFFSET)) {
   510					goto out_good;
   511				} else {
   512					key_control->flags |= FLOW_DIS_FIRST_FRAG;
   513					if (!(flags & FLOW_DISSECTOR_F_PARSE_1ST_FRAG))
   514						goto out_good;
   515				}
   516			}
   517	
   518			__skb_flow_dissect_ipv4(skb, flow_dissector,
   519						target_container, data, iph);
   520	
   521			if (flags & FLOW_DISSECTOR_F_STOP_AT_L3)
   522				goto out_good;
   523	
   524			break;
   525		}
   526		case htons(ETH_P_IPV6): {
   527			const struct ipv6hdr *iph;
   528			struct ipv6hdr _iph;
   529	
   530	ipv6:
   531			iph = __skb_header_pointer(skb, nhoff, sizeof(_iph), data, hlen, &_iph);
   532			if (!iph)
   533				goto out_bad;
   534	
   535			ip_proto = iph->nexthdr;
   536			nhoff += sizeof(struct ipv6hdr);
   537	
   538			if (dissector_uses_key(flow_dissector,
   539					       FLOW_DISSECTOR_KEY_IPV6_ADDRS)) {
   540				key_addrs = skb_flow_dissector_target(flow_dissector,
   541								      FLOW_DISSECTOR_KEY_IPV6_ADDRS,
   542								      target_container);
   543	
   544				memcpy(&key_addrs->v6addrs, &iph->saddr,
   545				       sizeof(key_addrs->v6addrs));
   546				key_control->addr_type = FLOW_DISSECTOR_KEY_IPV6_ADDRS;
   547			}
   548	
   549			if ((dissector_uses_key(flow_dissector,
   550						FLOW_DISSECTOR_KEY_FLOW_LABEL) ||
   551			     (flags & FLOW_DISSECTOR_F_STOP_AT_FLOW_LABEL)) &&
   552			    ip6_flowlabel(iph)) {
   553				__be32 flow_label = ip6_flowlabel(iph);
   554	
   555				if (dissector_uses_key(flow_dissector,
   556						       FLOW_DISSECTOR_KEY_FLOW_LABEL)) {
   557					key_tags = skb_flow_dissector_target(flow_dissector,
   558									     FLOW_DISSECTOR_KEY_FLOW_LABEL,
   559									     target_container);
   560					key_tags->flow_label = ntohl(flow_label);
   561				}
   562				if (flags & FLOW_DISSECTOR_F_STOP_AT_FLOW_LABEL)
   563					goto out_good;
   564			}
   565	
   566			__skb_flow_dissect_ipv6(skb, flow_dissector,
   567						target_container, data, iph);
   568	
   569			if (flags & FLOW_DISSECTOR_F_STOP_AT_L3)
   570				goto out_good;
   571	
   572			break;
   573		}
   574		case htons(ETH_P_8021AD):
   575		case htons(ETH_P_8021Q): {
   576			const struct vlan_hdr *vlan;
   577			struct vlan_hdr _vlan;
   578			bool vlan_tag_present = skb && skb_vlan_tag_present(skb);
   579	
   580			if (vlan_tag_present)
   581				proto = skb->protocol;
   582	
   583			if (!vlan_tag_present || eth_type_vlan(skb->protocol)) {
   584				vlan = __skb_header_pointer(skb, nhoff, sizeof(_vlan),
   585							    data, hlen, &_vlan);
   586				if (!vlan)
   587					goto out_bad;
   588				proto = vlan->h_vlan_encapsulated_proto;
   589				nhoff += sizeof(*vlan);
   590				if (skip_vlan)
   591					goto proto_again;
   592			}
   593	
   594			skip_vlan = true;
   595			if (dissector_uses_key(flow_dissector,
   596					       FLOW_DISSECTOR_KEY_VLAN)) {
   597				key_vlan = skb_flow_dissector_target(flow_dissector,
   598								     FLOW_DISSECTOR_KEY_VLAN,
   599								     target_container);
   600	
   601				if (vlan_tag_present) {
   602					key_vlan->vlan_id = skb_vlan_tag_get_id(skb);
   603					key_vlan->vlan_priority =
   604						(skb_vlan_tag_get_prio(skb) >> VLAN_PRIO_SHIFT);
   605				} else {
   606					key_vlan->vlan_id = ntohs(vlan->h_vlan_TCI) &
   607						VLAN_VID_MASK;
   608					key_vlan->vlan_priority =
   609						(ntohs(vlan->h_vlan_TCI) &
   610						 VLAN_PRIO_MASK) >> VLAN_PRIO_SHIFT;
   611				}
   612			}
   613	
   614			goto proto_again;
   615		}
   616		case htons(ETH_P_PPP_SES): {
   617			struct {
   618				struct pppoe_hdr hdr;
   619				__be16 proto;
   620			} *hdr, _hdr;
   621			hdr = __skb_header_pointer(skb, nhoff, sizeof(_hdr), data, hlen, &_hdr);
   622			if (!hdr)
   623				goto out_bad;
   624			proto = hdr->proto;
   625			nhoff += PPPOE_SES_HLEN;
   626			switch (proto) {
   627			case htons(PPP_IP):
   628				goto ip;
   629			case htons(PPP_IPV6):
   630				goto ipv6;
   631			default:
   632				goto out_bad;
   633			}
   634		}
   635		case htons(ETH_P_TIPC): {
   636			struct {
   637				__be32 pre[3];
   638				__be32 srcnode;
   639			} *hdr, _hdr;
   640			hdr = __skb_header_pointer(skb, nhoff, sizeof(_hdr), data, hlen, &_hdr);
   641			if (!hdr)
   642				goto out_bad;
   643	
   644			if (dissector_uses_key(flow_dissector,
   645					       FLOW_DISSECTOR_KEY_TIPC_ADDRS)) {
   646				key_addrs = skb_flow_dissector_target(flow_dissector,
   647								      FLOW_DISSECTOR_KEY_TIPC_ADDRS,
   648								      target_container);
   649				key_addrs->tipcaddrs.srcnode = hdr->srcnode;
   650				key_control->addr_type = FLOW_DISSECTOR_KEY_TIPC_ADDRS;
   651			}
   652			goto out_good;
   653		}
   654	
   655		case htons(ETH_P_MPLS_UC):
   656		case htons(ETH_P_MPLS_MC):
   657	mpls:
   658			switch (__skb_flow_dissect_mpls(skb, flow_dissector,
   659							target_container, data,
   660							nhoff, hlen)) {
   661			case FLOW_DISSECT_RET_OUT_GOOD:
   662				goto out_good;
   663			case FLOW_DISSECT_RET_OUT_BAD:
   664			default:
   665				goto out_bad;
   666			}
   667		case htons(ETH_P_FCOE):
   668			if ((hlen - nhoff) < FCOE_HEADER_LEN)
   669				goto out_bad;
   670	
   671			nhoff += FCOE_HEADER_LEN;
   672			goto out_good;
   673	
   674		case htons(ETH_P_ARP):
   675		case htons(ETH_P_RARP):
   676			switch (__skb_flow_dissect_arp(skb, flow_dissector,
   677						       target_container, data,
   678						       nhoff, hlen)) {
   679			case FLOW_DISSECT_RET_OUT_GOOD:
   680				goto out_good;
   681			case FLOW_DISSECT_RET_OUT_BAD:
   682			default:
   683				goto out_bad;
   684			}
   685		default:
   686			goto out_bad;
   687		}
   688	
   689	ip_proto_again:
   690		switch (ip_proto) {
   691		case IPPROTO_GRE:
   692			switch (__skb_flow_dissect_gre(skb, key_control, flow_dissector,
   693						       target_container, data,
   694						       &proto, &nhoff, &hlen, flags)) {
   695			case FLOW_DISSECT_RET_OUT_GOOD:
   696				goto out_good;
   697			case FLOW_DISSECT_RET_OUT_BAD:
   698				goto out_bad;
   699			case FLOW_DISSECT_RET_OUT_PROTO_AGAIN:
   700				goto proto_again;
   701			}
   702		case NEXTHDR_HOP:
   703		case NEXTHDR_ROUTING:
   704		case NEXTHDR_DEST: {
   705			u8 _opthdr[2], *opthdr;
   706	
   707			if (proto != htons(ETH_P_IPV6))
   708				break;
   709	
   710			opthdr = __skb_header_pointer(skb, nhoff, sizeof(_opthdr),
   711						      data, hlen, &_opthdr);
   712			if (!opthdr)
   713				goto out_bad;
   714	
   715			ip_proto = opthdr[0];
   716			nhoff += (opthdr[1] + 1) << 3;
   717	
   718			goto ip_proto_again;
   719		}
   720		case NEXTHDR_FRAGMENT: {
   721			struct frag_hdr _fh, *fh;
   722	
   723			if (proto != htons(ETH_P_IPV6))
   724				break;
   725	
   726			fh = __skb_header_pointer(skb, nhoff, sizeof(_fh),
   727						  data, hlen, &_fh);
   728	
   729			if (!fh)
   730				goto out_bad;
   731	
   732			key_control->flags |= FLOW_DIS_IS_FRAGMENT;
   733	
   734			nhoff += sizeof(_fh);
   735			ip_proto = fh->nexthdr;
   736	
   737			if (!(fh->frag_off & htons(IP6_OFFSET))) {
   738				key_control->flags |= FLOW_DIS_FIRST_FRAG;
   739				if (flags & FLOW_DISSECTOR_F_PARSE_1ST_FRAG)
   740					goto ip_proto_again;
   741			}
   742			goto out_good;
   743		}
   744		case IPPROTO_IPIP:
   745			proto = htons(ETH_P_IP);
   746	
   747			key_control->flags |= FLOW_DIS_ENCAPSULATION;
   748			if (flags & FLOW_DISSECTOR_F_STOP_AT_ENCAP)
   749				goto out_good;
   750	
   751			goto ip;
   752		case IPPROTO_IPV6:
   753			proto = htons(ETH_P_IPV6);
   754	
   755			key_control->flags |= FLOW_DIS_ENCAPSULATION;
   756			if (flags & FLOW_DISSECTOR_F_STOP_AT_ENCAP)
   757				goto out_good;
   758	
   759			goto ipv6;
   760		case IPPROTO_MPLS:
   761			proto = htons(ETH_P_MPLS_UC);
   762			goto mpls;
   763		case IPPROTO_TCP:
   764			__skb_flow_dissect_tcp(skb, flow_dissector, target_container,
   765					       data, nhoff, hlen);
   766			break;
   767		default:
   768			break;
   769		}
   770	
   771		if (dissector_uses_key(flow_dissector,
   772				       FLOW_DISSECTOR_KEY_PORTS)) {
   773			key_ports = skb_flow_dissector_target(flow_dissector,
   774							      FLOW_DISSECTOR_KEY_PORTS,
   775							      target_container);
   776			key_ports->ports = __skb_flow_get_ports(skb, nhoff, ip_proto,
   777								data, hlen);
   778		}
   779	
   780		if (dissector_uses_key(flow_dissector,
   781				       FLOW_DISSECTOR_KEY_ICMP)) {
   782			key_icmp = skb_flow_dissector_target(flow_dissector,
   783							     FLOW_DISSECTOR_KEY_ICMP,
   784							     target_container);
   785			key_icmp->icmp = skb_flow_get_be16(skb, nhoff, data, hlen);
   786		}
   787	
   788	out_good:
   789		ret = true;
   790	
   791		key_control->thoff = (u16)nhoff;
   792	out:
   793		key_basic->n_proto = proto;
   794		key_basic->ip_proto = ip_proto;
   795	
   796		return ret;
   797	
   798	out_bad:
   799		ret = false;
   800		key_control->thoff = min_t(u16, nhoff, skb ? skb->len : hlen);
   801		goto out;
   802	}
   803	EXPORT_SYMBOL(__skb_flow_dissect);
   804	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--ReaqsoxgOBHFXBhH
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

H4sICC0EdVkAAy5jb25maWcAlFxbc+M2sn7Pr1BNzsPuQzK+jePUKT9AICgiIgkYAGXJLyzH
o5m44susJW+Sf3+6AVIEQFBTZx+yo+7GvS9fN0D/+MOPM/K+f32+3z8+3D89/TP7un3Zvt3v
t59nXx6ftv87y8SsFmbGMm5+BuHy8eX974+P51eXs4ufT89/Pvnp7eF0tty+vWyfZvT15cvj
13do/vj68sOPIE5FnfNFe3kx52b2uJu9vO5nu+3+h46+vrpsz8+u//F+Dz94rY1qqOGibjNG
RcbUwBSNkY1pc6EqYq4/bJ++nJ/9hNP60EsQRQtol7uf1x/u3x7++Pj31eXHBzvLnV1E+3n7
xf0+tCsFXWZMtrqRUigzDKkNoUujCGVjXlU1ww87clUR2ao6a2Hluq14fX11jE/W16eXaQEq
KknMd/sJxILuasayNqtIi6KwCsOGuVqeXlh2yeqFKQbegtVMcdpyTZA/ZsybxZhY3DK+KEy8
HWTTFmTFWknbPKMDV91qVrVrWixIlrWkXAjFTVGN+6Wk5HMFk4dDLckm6r8guqWyaRXw1ike
oQVrS17D4fE7bwPspDQzjWwlU7YPohiJdqhnsWoOv3KutGlp0dTLCTlJFiwt5mbE50zVxKq2
FFrzeckiEd1oyeBYJ9i3pDZt0cAosoIDLGDOKQm7eaS0kqacj8awaqxbIQ2vYFsyMDrYI14v
piQzBodul0dKsJRoH3ltWNmatQlMGky8Lcndpl3oqW4bqcSceeycr1tGVLmB323FPH2QC0Ng
P0BbV6zU1+c9/WDqcMoaXMLHp8ffPz6/fn5/2u4+/k9Tk4qhdjCi2cefI5vn6qa9Fco7pnnD
yww2hbVs7cbTgcGbApQEtysX8J/WEI2Nrc9bWA/6hH7u/RtQ+h6VWLK6heXoSvpejpuW1SvY
EJx5xc31+VnPpApO31o2Bw348GHwqB2tNUynHCscDSlXTGnQMGyXILekMSI6vyVoJRzg4o7L
NGcOnLM0q7zzXYTPWd9NtZgYv7y7AMZhrd6sEkuNZha3wmn5rWL++u4YF6Z4nH2RmBFoImlK
ME+hDard9Yd/vby+bP/tHZ/e6BWXNNEY7B1Uv7ppWONZtE/FxtSU/lqdnoCZCLVpiYFAVSS6
zgtSZ74naTQDn+rZZANRPjoSa6eWgcOC0UfiaSp4H0OLmGgUY72VgMnNdu+/7/7Z7bfPg5Uc
Yg5YpPUJiXAELF2I2zSHFr7uIiUTFYGwmaCBHwbvCAvcjPuqNEfJScbQ7eEUvI6tm0wcAYoA
ZqHgaZ0HCVytlkRp1g176NZfne0314meKeIWLRro221+JmIn7otkxHjW6nNWEGczDLMlwei1
oWXiDKxnXI3O/hCrsT/wz7XRR5noFElGYaDjYgB7WpL91iTlKoHxI3OwxuqWeXzevu1S6mU4
XYILZqA/Xle1aIs7dKmVCA4UiBDQuch4ylJdK+4s6tDGUhPSBYAiiD/abp3S/VQBLHw097s/
Z3uY8+z+5fNst7/f72b3Dw+v7y/7x5ev0eQtQKFUNLVxuhOonz2XgZ2Yx1xnaFiUgcMAQW8X
Yk67Ove7xxCH4DFQPrsGRZuZTu11vWmB53cCPyGgwqamgpZ2wn7ziIRTSHUJ8yrL7gCT/hqF
HNRlCzpHgJDaGoz5AKDrMw/X8GWXQIwodrMGcimwhxxcE8/N9ekvB9etABUtW01yFsscsIv1
tA3kOw5pAFTNnP6nMN0crRsEmhrxPKC6Ni8b7TlbulCikdrfJAgNdJHcGSfsxjwmIHmmj/FV
NhFnO34Ovv+OqWMiHUg9JpKxFafsmATYByrv0aUwlR/jz+VR9si3D1FdoIF2UuBgU266YHQp
BagEOgMjfNiOWAFCAPVxcAPerw6OEmADUJLjQzxXUzw4vylWzcwUy6kiIkW7qrTMRueYGEjF
KDjhtBZhXrZJ2Vy5xEO1MFhlISxWpIKOXVjyQKzKIoAKhAiXAiWEo0DwUajli+j3hWdB9JAS
Ybi2GoOVhpoGvj4Ww8wy5dd6vNabcg3om9ci8w/auQCenXoVENcQHCZl0uaKtvoQtZFUyyVM
sSQG5+j5c5kPP5zT9Sdvx0rMtgLoylGTvHmAXVbge9tRwHdnP5B9pcCpd5y0RlpM68JhCtdD
O72pvC3qKW001kCfa1E2AF1greAHjnQKTlTbdBBy8JWPs62zjn+3dcX91NALBtO7jwPkjb9Z
OUzNq00wKYKt5IualLlnA3ZrLOGwVIuH8ixlSDJPHE8RpM6EC78zkq24Zn2r1BmgGthcxp+W
pLy9abhaekcDw8yJUtxqzTBbrJZkLDVdp7rQe3uAiYNi0NOTixHK6GqMcvv25fXt+f7lYTtj
/92+AFYigJoooiUAfQP8mOi8K2AgE1bXripbx0gq6Kpy7VsLp9Ja2lfdbO1g0P6SpMOYLpt5
ykOUwkvDsDXsqFqwPpWMLMuwysaXFlJ5nnNqC0lpG1Mi52UaCVJFNCQFQQhasjWjEc0elXA9
eeSegsbhVDWwSVfQSQz7W1NJyC3mzNdTwJUA5ZdsA86ElTlWNQJfNe5tAOk4PVtgBr8ANoTx
iiKIndI6lsOWcTzXpg5bRGgL9QMxISBRAMe3JK6JcNgmhGAwuThrXsb1LEdVzCQZEEXSDRwV
i0Z5yvcHfmlI161oIcQyYmKRF34bvmhEk8jMNJwM5jNdbhoXLYnGKGd4vumD8lhAA5ZwdYgE
dAWUsAGQg/mjjSa2vB/NUbEFOPI6c+X27mBaIuOF0jK1OpBzFh7xilswUUYc8op4FV+DBgxs
becQR2aEVnB8jaohxYM94H6AjL1Z4mAKojJE9BZAGkZNBytSnSTG7x2W6vYla6pYHe02p6yr
OxynLy4RoZXEknu8p47qyoQTvEw0E9VoBKaugNEXHhPz04yiy2zBc5gAYkzQbcsFAC1ZNgse
ImGPPGXrIGH3C03U7nkE30JmyknGMnD6dQwCIwk4vqYkE6nOSBqsQCT9symw6gGbBgglVge3
69yKOIXIFWYPsYcalwQm/EWNtSfW3SlgeT8lZ+8bIGJ6mleJrCnBQ6GvBMeNkCrhFSwHjFpU
47uX8W1YJMDWWDpMeaSw1VV48kJu+iq9KQO98RYEETBVpdMEHH/kdSAfryEewF7fgil7kxRl
huCtu7A5HzGIvcIMVEY2WCcaAlGeH4ltdqar7u6OLpOCVkbYJIGUfXVa3a7/X8I92kjsyODf
DQQK4zXyg/gkK27utCbZPGB56WNuFdgi6hE0XFCx+un3+9328+xPhxK/vb1+eXxy1TPPX4hV
N71jS7RiPbgJ4LRzRl2wdMG0YGg1XiYJK0CY75uiTQU0As3rk8hughqNW7ktD4MLJulEupNq
6mMSnQNOK1XXg1b0cBM0kaH1kjzlnjomem0VYKeI0Sfrca8H/jpVLu39Cl4ZwGYIiJt+H3MM
palD1PXp9fMhfantdSasQIKfxC0bVdQON5DECAQmqrqNJNCz2XuXzHZjK+XTIuo2EujqXn29
V769Pmx3u9e32f6fb67g+2V7v39/2+58Vb1DXzNVUQOYNvGWImcEEApzlaRhDpaF1fyej/g6
0D2UqKSN3skhF+DLcp52lvbOV2UAv8MR2dqAP8RL8SE5DgY80imyXcel1KOZkmroNFES7Ccm
dN5Wcx4UzzrakSIeDqAyen52up6Y2PkZBFYezMrVyUCDjAvErUWSLIUoig1gOUi8IfQvGubf
aMD2kxUPqzQ97diEWZ0YZgnZa9//kJWtqi4Bngg4pW3iGqYTyn4+379pOIhGlWyIfHMhjKtM
DF7h4uoy7YQ+XSXLVEA2mgZdAKmq0jGvupzqHoK24U3F+XfYx/nVUe5FmrucmNLylwn6VZpO
VaNF2nArCzLYRHmguuU1XpjSiYl07POJQMNKMtHvgomMLdanR7htOXFSdKP4enK/V5zQ8/Zs
mjmxd1jTmGiFrn/C1LtgHzo2a9lYvu1eFbnbnEtfpDyd5knAFuCJaz9/th765CQPi4vW12GF
okKQ6FeGB/+IOSFi3ZDnLMMjdOnb5UVIrnjNq6ayiDSHzLzcXH8KqkeYfWOSwkpGU8AQG0IM
dZPxwHJHtmcZPPHrOeDDE+KwTtKoMcNmKBUzJNlXU9GAXkhmDiWpjpb5Gbm+5SJ4DsVFVTVt
wUrpt6ntYy59fepvCWOVNDYLTPm8jr0SJfhFYqsgcdsjzaw3HcZvMJU3zF6GhOeGGyg5jQMj
HoRAxoQ628S+b+mrkkh2p5gSWE7Hu43u+RJ6bkwr0+HDqlQYjB3q8Yq2z68vj/vXt+Bm2y+d
dGpd2yLk87SEItJTuDGfRi8dfQkLIMQtnPVzOPmSQbq2gWxrIlpMMrDx6WX0ynW4OxfgB+ap
+0B+tQyPQjHc4pyv3Q1u76M4BVsEl5MgxbY3MAIbG8iYl1oflpPwPssen04XLqwTkQ1Ph4Ja
4PsGCOnpNNbxLlIooeNdXgRvGVaVliWAqfNUk555lmxymsYiC1g3pNnMXJ/8fXXi/hfNITwI
SeIqlyw2oDpZplrjCs4R3xYgk2z79MBGDBjGZvJBHcS2zsHUgduymiReg1poPs227rl/AAa5
k68PvEStLntIig98GjZkoum2h23tp1WRuiGpvHmYmhPxvGzPiQuubijM/oLceejJ3QeMm81D
JBmQu/0dVen7fH3RyPi8uKZEZX7HYeWlg6nulSd2n8KhbjGFMFiK9MwtoHdrC9BqKNA/GhQ2
Y53AW30LBf9aJa+arQlIYzfExq6LYMlOe3ox9IIm3FJ7n9UXrA6eY6FISDpiCi47EFhAG4hL
7SlBv1RrCe5pV6auL05+vfQ8ZqIkOV3McpcLpgDDuiWp5Dh4nL0MEg9aMlJbsJYu2FYpt30n
hSiH6HQ3bzxPe3eeg4v1Q8udHl8zdqxePe1j5/5KaapIATvHlMJKhL06cW6tQwfeDeeEUCr8
4G2PFcA7o2X0osxdo7ejV1+BY5cmvXE2YOBrl3YOWTfeKapGxheVQeADJLvCYs/t9eVFAM9B
b6umHN1y9gJGBWV9/N1qAgvmUw+OnH+fLHS6UnUYDrQ7lqALBzQAWScHYTlPWai76PCc1F17
enIS+J679uzTSXrD79rzk0kW9HOSCrF316dDsHOlikLha0LPQPHiNzALezuM10ypcArmzxFK
gmoojKinXUD13/sA1rTv2Y61t9kNtD8L4nF3qb7KdPBegVaZreaBW04FIghdeDVZZmb8EMJ3
flMeOy3jXO2hfPf61/ZtBkD2/uv2efuytwU8QiWfvX7Dj5689wfdfYAX3rovOoaKYMTQSw4O
bFN7gU9CLCwZkwEFn2ONqbdkyaLao0/tvi3wFCHgLoJBgy6i+1ScQLbCp1BZgmXnlaBHt9c9
pVUmXK271j0c+e2Nw+neXcmRSwrq39fgrx7PWz3UQx3ZP/EKv1bqblqwifS/TrKU7sWFm4jN
KrT3BdgQiWh/+bxIFv5cX925ha0w0c61GyEd5VBKsVULuqgUz9jhu6BpcUaPPBe3EiRe6ZwY
QIibmNoYA8H/Oep/BdMQU13npB7Co9uZsPjeL9vVFw7J2nhfrMDUMLTRRoCKajD6PP5GJpY4
duljZd3z20YC3PEzre/yInV3U6d42CLK21Hv46cybpqiNgSc25Hj75Gi801TO9JLuTpArMlz
HVEgFowOttuyiplCpN5udcqYNegC8F3DLeA0BK6e4gz2RCQbPVLp6d07iXB4ZCR3IZMmP2Ij
Eu9vBGQVizRO6PcZ/p3rQTl1Hk5BBjls/0h/lr9t//O+fXn4Z7Z7uI9vFm35TLGbZEv++Wkb
CyPumoaziFb1QQ6rQrIMX9HZ/ubvuz7szP4F+jbb7h9+/rdXVaHexqM+LgRCsQDhWWpVuZ/p
bbUiGVds4lW1EyB1SiWR143pUdxHMhGR1vOzk5K5p4UBi6GnDdKJXsmxHQqE4iS0LySBM1TJ
r62cOCC53xg1cSuiZaowbDuUFRsNksn0Q0LXwEz05Z4aJHMp5FaajwgTHyDZvZ348gh5yn20
2YOc8ANA67BM4xVFCxN+AYUSiBZKZj9KRFo8OherSR2RKm3Wlkc0T7kaO2T4msk7+wA0eyph
8eNNojtfiM+rwQn4jA5GJHu2PgRafqdvGphezGnvzKdPn058vzsS6dLC74yjC0l7aJptd49f
X27v37Yz9AX0Ff6h3799e33b+97HKeqtvT8d12mh4R+vu/3s4fVl//b69ARg9/Pb43/dw9qD
CHv5/O318WUfuBrQqqx/XhecbU8/+N6Jc2Yyb7uHn4eRdn897h/+SE/H19tbLOkbWhjmf7rj
nvGEhO6VoD9JIKcSNYpZiX9IjlIoF8JTEabkwauVmsFBn5wmJBfM94lYjq7nvqFhXcorftOK
chL/tm9EWhpeRGNDWHPiZH96uH/7PPv97fHz1/CtwQYvXVJnkl3+cvbrMCq/Ojv59cyfha2e
1aKOy3UKNjjjYhDtCK3R/Jez0zEdK3F2V0Vjrs/9NLIT6DyWWrdm3dpaSGLCh97giFm94OE7
vQN3wkEOQzUVPtmBBT2PW9OiIilw0fMrnFxLM7aC1u7ruPtvj5+5mGmnyiP99fbm0y/r8d5Q
qdt1go7yl1dpefAeZ2OOWlvO+cCxhY2Nzue9zbG/tw/v+/vfn7b2z3/M7K3Nfjf7OGPP70/3
UYo753VeGXzdN5w9/Aifj3dCmiouRx8X43n7z3qcLJITe9xxKx5e++NwE3WKrpBwHn+y3j32
4SKotYG59vtQb/d/vb79CTDPS+y9RxB0yVIzbOrQAeBvUG6S0rd17n8ugr/sX78IbqSQqJs5
aHzJaQpfWQlXnw3+qAc+w9sM59wRPMnB+dUsDeuAjn8SAQtWFVHpZ4fYrzQSsnYC2Wi+OdqR
LDbWxsFbVDJ6MuILuyfAaXScxFDayGGpc8iOF8zfRUdpVyWpu+fF6fcqVuDq5Oz0xm89UNvF
SqW/gPNkqimZjNE6qTNlSYfZw48zf3QuU4+QiCHlcmiE388RCSlCSOYyy2T0E7wb9VV+ffbJ
H64kMvV5iiyEs41hXowxXPCn1N8/QK2wVcbemm7et+9bsKWP+uGP7ef3p+Dut5Nu6fwmVFgk
FmYeBVRHznXyi+yODUhThNaAVPthW3C2PUclP1HquegeRxPTebInw25SpckDe56P57VQLBtT
M41WN6bD/4cPpw4NVNpmDsu/wW05KkILsUyVa3v+TZ44ImpvDEfk/KbjjFaQ34xpRZGPu5Cc
pfYY0e/RZSQqhM57P93vdo9fHh/6v0/ltaPhE/GO5HDA5GAoYSivM5a+Aehl8tuJTUVmE7xo
cYToy5CeOtYI5Ci9kuHm9dTLMTkv7R/OGE2Rjr7vjXdC5vFh9P1NOOtepMLv1aMnxp4Iq8I/
FTLQ3Ht378/heCxayXgZHaeeb8yUEnciuOXPycb4xOh4W8PWJrWBJPk8qufyOmHiOc89N5VR
LwPIavwKSQv8Yz0BQIIISPDCdJUKYPj9OQsf9q4qW5xbQcJw4KeacmUAIR56eJ5g9H8kI9y9
ktfLEcwZ7uNk8tvSQocf47jP5i2imPJTnoxDHFNuG/IESII2bfiF7fymjPDdbL/d7aNaXkEq
RbKpGSTBP1cZ6eE+f8sIfn6wf314ffKwMlclCfaNqzQe+D/CnmRLcVzZX2H1TveiXoOBTFj0
QggDKjyVZcDUxie7ku7Kc3Ook5n1bvXfvwhJtiU5lCxqICI0WkMoRlHiHLuUa9bAgVaywZGm
WhuonlQBE/EMzb4T6eouFV4ZhJfUM1ahW5m2bub579e718v9J5QmjO4v//fw7eILBqQoh5iu
xqo6N0DRztL65fkfeF68dfKJdt3n2daNpxJLYaCkSLcS8H5pi3Wrtor3JUt7sGWIJdJpBEfp
sMqeCRJVrFd0mCZlN+PxRwRbUa5E8mEVvIgmEVWJIUAzrVWc7DGc0GAgMPJoPKYaUPO7oT5G
v2XhtY0UVLdOIlvl2drHd/OnDNkQ60hGUgxPxAe1tp1NhCnRMcxS+HUcBQsUX7lvRPS2jtd0
7wEZmG6FWVMHEWAsn+MeaJRn7R5YPf68vL+8vH8PrnIo45niAWTHxYGVFQVrdjNvYC1ixSV1
F1sUrNpN94HS05MoqQVlkbT9pBunrfgski+cuiXt7m1v6pocc1oeiYbXVULbimv0qppS/L5B
JofYlZe1hdTEe9Aj/HFgpkM94IQO83tneVdlDMeJMuGiFijOd+L4QLWQJrZjIZ7gl+dcr0Bu
ICEFkrZFtyESR+fC3GzxBUZJFxOxUqi+hhbS8PJcwBBt2wEPx3kaRlZ7QSGdy6Lr2PPlcv82
en8Z/XUZXZ5RqHSPAqVRyrgi6HdOC0GOTzllYgRTbSQ5to8mgFKyt81euBFBNARWeUEKkgx6
W9gySuQbloXPFy4LwwIFOI3lwNiBM7FxJbJiExQ6KiTUg/JCv8xBUm/xbOMIv+AncF5bUZG2
mYjN7PVuAI3ZGU41sDEG90h2uXsdbR4ujxhh4+np57N5PI1+gxK/m5PQOgKxns268KsGUCMi
8skO2CKbTy232Q6ERVyw2qtPPoQcjUKE2wTeZzAxGqZadSesLohZ1EBD7TQtp5tTmc0DrReS
AUfsxoyDhSQ2AW7kVB0yz2O1FyphhD7fdLHlQMq84XGSWKcStgMrTR1vvXUnOysHxh5h1Enq
klu7TJ6KbfrwzYBH+VA2etAhU7QrBdEtaKZKi40Xk0XDmhT9H8iRwsGQrVkS9LpQjQL7oJ87
KpJbP8TNSelKbJurjhS4K+0SbImwa2C1Owor8lRXj47E4LuLkGjgs5MEvcYtdU8Cj2YltWtF
1+5koH/eGk77wLvaEMTHMhARRRMgP2OqaYL2woqIoc1ZS6qDbtqXH/DXvc8izey2oRiLg3HH
pPgsmwpVz154zzLeOtJ4/ds9AwwsTW35XkvoRs1EJZAKi7zGiHsbdy4784nBAQb/ZDpQRLfb
08oxkYGf2n+WGCLioEXlJAPcgv2QtlHamAINDLXd+adJsAIVo0aZUsZOIKghIUY6QBucQLda
40miW6y87cBaWXj3+v6gjvkfd69v1vY/wI9RqmMqq7BL1evd85vWC42Su38ddhirzvPCawwb
EmjJCx8mhSdo7xoNL7Y/yjz9Y/N49/Z99O37ww/q7aLGsgk4BwLuc7yOuVpagYnAtbJi8Lw7
Ade5aywmicBGH2Jn/hfx8AF3TaITAf/LIeU0Cn3fDdxF3mAULPI7qaABj9QWvQgtbpb6e6HM
A76vuLJW6OEx2Hnp3Y8fqFozn1cxhep7331D53h3CaEOL4lrnAjUGkl3iGhJjMfGEwE06j+y
QGe5vHBdgWySJM7+JBH4PdTn+DNyx1vw8MLUSvvAvCIrqt0gvNnVJuZHDDtD3aaq4oRVxHdJ
lLgS6xzMv7w8/v0JbSruHp6BJwfq4JtWNZDy+Xzi16+h6LC6EQFP3p4qxP8iiUx0752JJgYE
fwA6GMz64e0/n/LnTxwX0IBrscqvc761dN8rpbvI4P5L/5zMhtCqd53B0hnGpIo5dzvaQlEC
4q4zxBC0UH+ghpUtBFfzkvbSVr/AOsbQZUGEMo4aIs2Dx5lVhcjVqoahK8Yp8J0UJVzg+Y6s
Yy3kPlfu4sHFoOngM1Baw46As01MtsDlfD6lHoAdBf4lxWDlKFwbMCJQHi6k4SczQB1n79yc
SmGr2W2K1lGcLJ5XBV0qqpHf2uJiN5dgUuCG/R/9bzSCQ2P0dHl6ef2X3pqKzG30i/JWa9k4
ez0VAk8RF5hWi8mvXwbuTJohV2+DmTIDAI6FYnqQUB9T8D/LrtYG9zFAnNYPKzEANKdExW2S
O3SiUl5hHsEqXhlvhmjs41Cq7QaoMohtcohVa90g8w0xGN8lQMc0c5O9tACrLgNqQgagBr0l
1dYtltWLxe3SUtq1iEm0mA2axzB0TWF7T2TOOwJ+mpdAGkvJtjFhFDZUU0ApY/+ob+qHt29D
JhkudXgKoEuJnCbHcWTH5VrPo3ndrIvc9Y3owYFnMTyD0rNi4nuLhVUKbxPbGWXHsiq31pDc
oskptyanEpu0Ma7jvdQfgbd1TcnKBJfLaSRnY4t3ijOe5BID5aBLGj5n+ibVITRv0s22qGho
59+Ig7m1hDqaRkVDMYFFJWmUvIPHTOIc1KxYy+ViHDFSkyZkEi3HYydau4ZFlDtY+/UqINFm
qB5itZvc3o776WjhqhfLce0Yrqb8ZjqnA2us5eRmQaOMWnKFb5tQ6FLlcU2GSz3IlbH3bDaS
LWcLu7P6MO0qsexPXQk/j9xdrX/DOoQKWNlEEzU12iouLpDLHWirNLxhVTTrZ9EAtefRAJyy
+mZxO3c0XBqznPKaCnRj0MBuNovlroilJVfnq9vJuHEjJWiYL5TsgbCl5CFVnpidbqO6/Lp7
G4nnt/fXn08qpu7bd9T3jd7xfaeUfo/AKo7u4Th4+IH/tcP8Ay89XER4NhjhmGqCPb5fXu9G
m2LLRn8/vD79Fw2V71/++/z4cnc/0nl67HceQ0Mthmx6QUk2jetl7BrytkD481GZpqqta9xS
kXdK3Of3y+MoFVwJCTQ32ek5udgQ4GNeENC+oh2aVYeQHE1ziWaC9C8/ujhi8v3u/QJPqs4l
8Teey/R3X3KH/euqa0eOGWqa0vP6jfkuoPyuExXLLohkm0MrRoJ3f5AsEdSm1gEr152rpeRS
tM+Swc5DJDp82v1WsGDMNEQaUwWSYHOQntuQnvM4jkeT6XI2+m3z8Ho5wZ/fre70xUUZB9Ru
LQoubGkpdVLGYUHm6GSrpsyNBcg4+jynOXBfq4qyOdBKA+EkC1CGEY56Sd2q1iH05QCvg69u
3BMsVcUs8Ipn/BiM8sQ4cIUh2x98ReUBZSyg0TQjaDaESOUSV8J/SDFyVq1avYltpY1yJUrj
Ux2y5qimR2VKsgNoHGM7552xd0FzR3uKklBiEeAXvRb1qmCwe/vDk5BjKRVPVVHiOoWSylmU
2cHpe7jjI6zAO2lx0gqiR2IxNdUO5dy2OGTt67+AKVkDyz/luWNiaPwNpnx+S8uNeoLFkr7v
4WoNGMlV52KXkw57Vo/YmhWV66BuQEqQs6F3nl3BNi5du5JqMiUj/NmFEsbxyade5v1RksAb
mAwv7hStYjfoK+NxJujdYu66Sl4bRMq+upXCM7L7sNfKOocl/FxMJhMsHPiiUHZKM2/ma2cp
D50M6NBSb1cBF0eDNNF9eciSt+04nFlZJZh7zLXIktNwnBPX1ZFVCT0cFrI9QERgCIAJfcqw
KWjbt0OZlyErQ87WsZdlBI5ZUhHc16izaLl7djWjt+qKpyiroLVsq6ym54iHlm4ltnk2DVZG
TwZgrqxWGBHXftZWodCcmTKcHcUhJZcD38WJdJNfGFBT0d++Q9Oz2KOPlBTBblpInrtbNjCV
vG4wgQ79lLq6v9fu6agu9UNCZky0SxmVb99QEtH8kTxkawz68HF9GKcldlxgVnF0te/xVzdr
n42qmWMmKqOAZeax3l7p2+bwWVTyQFxsm/T4ebK4chnsHOnKrpiQsVasAgMbq5gugmDrFa5+
xv7vZneyA6OLreWTAD8A7eWuA+CRTmMl4PClXkd4JluV6iN6UK0Crzmd3kRhQ83OxvRhiohA
mU06GVNhnu1ZXkTz2llxn8nHn1UEnvfH2DUYSo9pyOQ3Rb6RNSuaP5b7QFwquT9Tqjq7G9AH
luVO39OknjVxgN1GHLL3Iez8Q6w8fYgO+ii0vRW8dJfzXi4WM/q6QNR8AtXSLP5efoWidVBd
tolZkl3ZjhkDdsmNHmFA9P0rF9MFKQ6z64wxF0PuevZnmytn6GK6HBOHCqvDnnXRPjh2U7oI
eIvZvT2KtWKL+nlTmUU9lm5YMN8Lt7+7JsSrYQiQEH+mvSAJT9sd8KlwoJMVnmM0ftmIK/z+
lyTfuvFIvyRsWtc0P/ElCfInX5LA/oTG6jhrguWCLmFtD+ElrQz17T4CAP1ErnC0GIahivcu
c0przRaT6ZKHUVVOn1nlYnKzvNaJLJZMkpduuXamvrwZz67snBLdQ0qyMslS4B0cCZNUl8jV
dSrj+AtdpUBfCkf0s4zGU0q875RyQ7YLuQyEUgPUZHllxDJP4N0Jf5ylLzf0cpJoBIkL5sq6
l6nr22xOA5ny5QTGSO/RQvBJaCRQ33IyobeNQs6uHYqyUpFjnVFWqRJQXf2ABzedLiuKcxoz
+lLARRKIH8vR1ycLHOyCyvNndaKKd4fKOfA05EoptwRG5YALlAXkWVVC+gVZ9R3dkxqdHcpd
KNAnYo8YmE2Q8iGr2pP4mrmeuRrSnOahJdERTK8xsLVyRSKWIyKi4ooERJ6zvJBn19DzxJs6
2dIn5Ga9tmRY63hTO5omBVCmf0RZud8MTLflKhAPMdVhIFB46grDMI/Qitk5khRUmU1YSsiz
kzRdngqVP1zrS4UYwc+gOY0KPL2zJLKtdKMp7CTkrFqMp7ULg4f7LVyABmi/5xe3GkwMFbD6
rm473ZczMoNAQS7g/c1MX/uNiOnfMhYos4YHuKnRkkAXwHjNFn63FfjmNlDTRqVkc+oRvEgO
0q9Gq3TqEzsHakJHo7iajCcT7taX1JULMK8Cv4UWPBlvA01oznhQToXbhmftB6VyZFfdXmTM
pGXyZv5LS0pUZfgJtyI83D1IBU/J2jKVQ6EjLA7BpUt4FFUsZewu1Bq9YupmCys8KvFva0ck
wqq1KNwfmFdcRTx1gLCbMbS9Y0NRtOnfiDEiMi2KQQHl1O8rdXp8PiigjJ1pzrvQ0Td9qbwt
+KWeAjLZdVpO1PJ9enu4v4zQe8PoiVSZy+XeuL8gpvU/Zfd3P94vr0MF18njcDqHolMgDTcW
6KXlKawHoqsOUeVItTHKbjjHDGDngzcLWWnqPhJtZHvkXO2/kpldpVJ7/0p/VMRzYBf7xYoq
TydGuPrdW/uHEPDcciwLDLpIrNA8Lcw2vjMwLp2FWAqZkrEz7M73cgoKGcPjT78iCGzJfMGe
g9UHxpXmSzvwnI2wrShsuMsz2Ziv5zWj2AWbRl2EcZZZgn7DbpTszDvb9Fg5ko1OD+gL9tsw
Ts/v6HD2drmM3r+3VIT27UTya0ZC2MTOxxJyTeiFn3/8fA+qp5XjmXtPAWDggOqhNxuM7ZnQ
qWs1CSpGta+YA9bR5feO4ZvGpKwqRb3XJtKdDf8jhi1+wITJf999c6OBmWKoeIaGgh35nJ+1
7tWBxkeic/HR8STHeQuZ6eoC+/i8ylnp6KtaGJxt9OltERTzeUTzvi7RgrbP94iod3RPUu1X
dD+/ANNxe6UXX6pocnOFZm2CK5Q3i/nHlMke+vIxCXKy1ynUKouvVFVxdjML+C3YRIvZ5Mo0
6yV6ZWzpYhrRaiaHZnqFBo6D2+mc1lH3RJzepT1BUU4iWm/U0WTxqQrYDHQ0eRGrNDdXmjMS
lCtEVX5iwAdfoTpkVxdJlUZNlR/4DiBXKE/JbDy9soDr6mqLyAk3MfUmtE4ji1PHn00hXc+W
FgiP9IDtUU+yOodSZ7YUKH+EfwuK4eupgF1kBTLQdE86NHDjXlBGgpqfVT7MDxtMxAbzA+2J
ydAZHAYROHs8ZmtDW4Yr3UCPnTgR1New2lLrww5V2+M2mGTKN5ro0cdU/T9YvYxLwZJhWR3h
DNv9YADw3p0vb0n3AoXnZ1ZYgTQ1ECfG+Bl61bUY32Y5RHbtMx8lvOAZ6QSk8K5HupmPbhGR
XezRnr+4d6PDhS0x5UNwk6kA587S0RBlbct4zAPpZm0qUXhsJUW1YxmwX/RxZpHtV/DjGlER
b5k8UHvGEOnVBPwevDtmQ45MrScJ7/eAzs2cP4K02y9TMfOMbxXIcSBXEFgXjpkawjbjaajO
aG3MaPvtpYuokA5eNRNaKqyRU0r+ZVCzYV1zh8XQL9q713tlqyv+yEfI5Tp+AE6gPcJ3wqNQ
PxuxGM8iHwh/u/bYGsyrRcRvJ2MfDgwvcl62n7KGczy2qVe6Qidipe8NB1qykw8yJllI/OS1
LCMUOgybhuE3XtsdxUGREN3asjT2E0m0sCaTwH+S9XUkCW2f0uHj9DAZ78kQxC3JJl2MJ+3r
gH+/e737hiKJgddHVTkCrmMoAOpy0RSVK/c1aTgQHPg0sEd1IOFs7XH+SrVUYU8pMeWZJ2zt
+Gecv+Krv7RvppppYUHimgApBIZZpMN7oCzIRILxILYwq4U1WzvfW/41t/NNCts6M2t268Q1
1mm2kpaKmCQpmIWRDMek0NK34YmPoUx8gNp7OOMR+vpw9ziUV5tPo5JTcTsBmEEsovmYBEJL
wM0ot3WTal7SdJ7Xko3a4EejLiybiGsz40AnUhZo1RbR2Ahlb0RiuKThWanij1iZ1mxsiemR
0/gjkjZPdmgaUpadgzGvbUIV7sAN2e9+kQoT/XlxEpzOyoDxvP1RZEB9Z7dE2ZI4DVXRYlGH
uoEpv6+2kZLB/xwK2N7tsZa9PH9CINCqha7EsoQZvymPXwvDwIVbcM3sLWBwQX6WqX9nYAIt
zrOalCq3+MmNkKjgIVvs0GGMG0HDYGFNruJyzeygeQZlbr7PFdu68bNc/DUcPrXVoh0septo
xQ5rFZF6MplHVo4yTYmWKXQ75XBIeP2G5h5xsE91fyYesiyiQQGA9Ru7D0BqsLAHYJGasG7+
F+2RbXc+WstpnDVfJ1NatGNoMFLMimZyK0yjCcekdUmp366HR1J82JWioCV9u2MbFcbWDSn/
iHainVDVqUDefk07bOxObVo923uwBeqUCiL37qYBmbapfBoi0LydAKtM4xTiqPIpEB0JRvuy
+lo4g1CKAYrNni5vZq4XZ4GuA2QI8zw7F537mQkV8S3Mi3Vch30rYRA8jA47c+xJe+jMy2ZR
RjNa7CaKVt1EvVRPjlOKTorhvVwLvrid3vzyNOcYdtJA+okvSDM3WEdbnTzSS+Nd8a2af/uZ
iiBBbg+NUU9zrZl6GhTTz3uAZDFpnGOTZYdj7mVCQ3QmA7bxfKubDWKpdh0CXlKmuog5wiyg
l399JuaikdV0+rWIZgFna9hEyg3ZNrc4us+vWiTJGbOn2PkIDEwlkRmqRKCpoSbElVno/DnR
h3m6EK3kghjIwOKhIz4I6KJgmIHMUUUAMD3U7WZKfz6+P/x4vPyCfYRdVHFCqH5iIW8dt9Ck
4rPp+GaIKDhbzmdObBQX9SswQEUhMl6VybBWmBqqxjSpeZHQUhikMQHHMLZWoFUln+pUMTAZ
7PGfl9eH9+9Pb+5UYCYKJxNVCyz4hgL24Y+h0k5kgP6w/Uybo20EnQB4OM2QMyaWiMncvR59
7M3UnywFrmlVgMKn69s55WttkOgZ5dcpFmQiH4WSrqxTw1IyuDOgCiHqmTuJmbLcjUhgI2fL
xdxdJFLI+Xw59xsF8A0p8THI5U3tNuHdggYEp8pgc6scp8O4zlgvT4X99d/+fXu/PI3+wuhq
Jr7Tb0/wsR//HV2e/rrcoxnEH4bqE7DlGPjpd7dKjmfMcCfCO19sM6WMd5lhD9nFGvGmxyJR
npWBibJr4sKfHwu7Ymd4gAv6eEfaeBuNaRNwhU3jIyWpQpx/TSJsH6cf7f58oEmy1xxndggW
p2BRs4Blh142qZtUC2DaFujPLmcQsCjP8KgC1B96c98ZsxZywRDhUyxwk6AAMdCZiqGi6Ji2
6y1//65PddOutei8FaU1TI2OpemyQYp/oX3s1ARgTjyvr4Pl4y0RDLMQdLboSfDsvEIS0ifI
gjaHlUVKfUnHPRh+OBeslvNKYR3HXdgABX58wJgQ/YxiBXjt2iZdblrJQg6NifT5X8i2Pur9
jQWBscXYKPtQljWLJsHEYU4vWky/yIY4c7J0/fkHg5revb+8Dm+rqoDevnz7j48wVijarFIl
gc5CWY4sc5S7+3sVVhH2iqr17X+twDtV0Uzmi4WJD1PY0cBaRqFNjPfw7H2qng4ZH6cc/K8H
tCE4e4QlGcTlZlqiZl1jfD/iFozR7KdyTEurWyJZT+Zjyq+nJWhPVKoFeA6U5fkoYkq41BJ5
8de7eoFPrlxHtq5almV5lrB94G1syLZxKjJxlUweslLIWGlhKZk7rDzHePj/KbuS5raRZP1X
FHOajhhHYCEWHvoAAiCJFrEYABf5glDLtMxoS1RI8rT9fv3LrMJSSxbcc7AVzC9RS9aWVZWV
yf3+SXGrex48p5NfRfIWkrdU7HuM4NYotMEfmUxl5g/WpBpzz2JP9y8vsCgz4xBt9uQlzBMx
dhunnSrHWoozIyMnRzqGFAPl01WxoOKiLcKZrFox2u6uOGkSllnytPhkO4GpHDkMsX2llORw
Cj1vHGMw2D/0gsGbrxnhrAMbDzNVQWRtaMy/IWoFNNf0UoMxHBvbjxehNqWi0sWKd/7xAjMR
0Xrc2EltP06Vz4uFXmIp4mFUR68n2+eQbvl6eB3yuIZKdU1zAUPbKoudkF378Z66Tv5BHR1L
k2pc38FMjEezpL7HeZhjLkUIf0TFp65td1rBdTVM6puVu1y42ke7KgxmZBTt8kgdwXXstV7o
KlTh4FYBqsb3rNDXsmaAY1MeXSc89E+a6BiwtCkVlePc+kfL8LjNGgw2qIpc4cpD16P2KgO6
XC6m87DsF63f79lkkaza8KR3vBxWiZJ6uNR31y3Rw7OOBdA0mLvx5kpi1yEdihyFch1tPDod
erX94e9Lv03O72E/JNYLOLl7ZGYfV0r1mLCkcRYGF2sik300GF2PPKploFi+5tv9f89y0ZgC
3KGTDcEb30hv8pQiY2EtTxKGAIRGgLm27l2oi0WfeGzKlEJOxTd+7PzyY9c2lM11DdV0XZh5
YmOWLjUaRY7At+gsg9AI2EoXGaEwtUhT84Fl9dEJLDnUcYVR3broQG8+OAq7TfLslqPNvqp2
wqMSkap6p6vwpRHiwpLTqwVREmPQM+ii0nMYWIzCpePxr6i6sdmlT1R6+te0+kcj3OfUtwCR
rsggtoRElxpCQuiROrA0K4PPNNhqbVB4Bnz4HttReSKtFiJa2p60SDIt7mSUI8KgI6z3KajA
0X4j3KUMaUJT2AHeLWjC6BEp1t5QF1ALPMt3qaE3sLA2toQRNgDTwqMAuMo6gU6Xj5Km9Av0
CiVKY0yojV3fo877pMItQz1VaISF7Z2oVBlEvisWORwvmEQpAoHrGVL1wiVthDv2nHzlLiht
dBQpVxICvRFZq6NAnOWC7Nh161mz7Vi3y4UnTPuDTxHxZ3fIEpXUH6PwPRC/xb9/BwWcslLp
HZSusna/2dd78cJYgVwCS4KFvTDQQ4qe25YjrAky4Jm+8E3A0pCUS+exdBaUd9akDU424c4V
gYUt3/1JENXPJQ7fMaRKeollgEdm18SB78xldxu2qRh+aqTbFg2so9z2tuNEr2aINsPoml0v
PnsdTBeySknnDyNDe6qIhkka3yHEgU5wxZD3Ix0flTay/4gBy7xbUGlp49ex4rDrtDzK+ZTI
ETrrDZXDOvDcwDNZ2XCePLbdIHSNL27GtGDnms8JbN2CirlvozZtqLJsdp4dNuSt+MThWKIj
6BGAVTrSZQtkosfyzXpU6Mg22/q2SzReBl8o09XURp5FfIGnvn1P1ZuVPhEY4D/ihUN9Bn27
th3Di6bJ3W6RRqQHrJGDTeGeXmQGLMmxgPeeNrkOihyO7VHlZpBD2+IKHIYiLRzfMqbqzxUJ
1Q7f8olkGWIv9Q7AAD+k8kNoGcwPlOjk+y71TkzikG2eBcAjK8qgX+fs2gGpUkyjuHItagJq
Y98jFr1d7ruk3POAWuQFmO4EeTBfBWCgNkMTHNLdABT8+c8MxQl/VRyDKiUwzHbpfEloGED1
HNngXoIWs0OMcRBaBbeyISYhBBZMEdayK9qYb9uzpiUjyoyMcQsjgqgLAkFAFAcA2BMRnRyB
pbWgyrkOvaXQN6ucW5yofDQZdSSH1jSy2vWcWU1jlzuwASFUMjYdBoTa1wNonbHfRW1ZG6Yn
N7QpewVleiKGHiCOFXjEWMVxvlgsyDkadyK+4SnrONarZgEbsbmOu4+TpUVrRAg5JgdDPc+n
nU97NxwYmm1rk00FwGxDAe7+0EUC5JjQwibLCFXfylM7cAM9oRT0nIVFznkAObZF25EIPP7R
sejXoGOp8iZeBPk/YzK4eZLZVu5yTpcAlczzmdFwTmovDHcCA+D6BNC2DfZNHchzWMKo0Rnb
TpiEdqh/E4FWbNHdAaAgdOaWhAgkHjo2qWEVkWPNLcTIIJ8JC4jrGB71Tksm+bRwhLd57BHT
cZtXsMmjMmXIfP9iLHPiAAYpeIlIp6WE7qXiao9q6mzWwOeHPvVaceRobcem82hDh3TINjAc
Q9hc2An1LUJLm7Z0kXicf8AzL13GMjdbA8MuCL2WWH445BcbqmUBhPG1ndufcZZ0uyaSZseX
w7EHbXs1Dgc0qTTtf9tbyxYfz7GlPxJMDnsCGiPVm7TAR1qYVLnGmMW76K7LGzEE88DONkVE
3QYcI2XhA8yurTPZNGTgGILkbMoDeiaqumNmiCxBfbGOspq/d5kphPgBi8jaVJHsWpvi7I++
edBNUkUavpILoglZrhoNo7exTnY5JsLzpf5FaTV+dM7M3EtRlk7MkRZLLd5F4gO3PoZXGXdJ
C9Nk2ayVN68yw9TDpr4LHO7COqENzOsT9cysZ9C7J+vcQ/lr2XKL57tCP155Fg9ctD0Vr128
neUS7xwIvp7riHEVk1JosYGihnYfyEV5jO7KfUtA/L1Ex8K4pgWOGGlGHPmYiYd2P3e8f3/4
+vn6qPtTmeajct2OyRC1SaKl5TtTpcQrpCSCTxPqiqe/XhFEMX7V+wmbyfJTltV47STk2SO9
83sCSY6E3Pt7ALIYuHt2T7PliOKPewzLAlWc0oySA/eSoJB3WY52yIz6JFIDUGRk3nQVd7AJ
WPTUsUjsxC5MVZEKpnvosxGUDPKdMD5kkXNvIJ911lYx3Xzpvi6HilADfhVAZjzBaZys8qgh
79OiNUwzUvaZ71pW2qwUaopqpySPDGqkMCFl9BFaqe+f8ZzMdtamggMqZ7CtiM7BzTTUCm4r
IHRFnqG//DLJCqpjNKC49rJRn7koybGNtu0aSlocsDHFmvkWFw6V6SoGfUDNdRUHzsKSpQeq
m6ewoa+/3n5IR9xgFfQiE4qOSqBhcPeqi5wSUMMgWMtFAeJSI6Lz509aPbq0gu2IS3bVKTCX
aWwU2RIdYhrknMWBZYdKKdKii5xhaA5mJB/+vH87f54mTgy8JRpQxlkVU9MJpKKYSMsTcPV6
fr88na/f3282V5iDn6+SLccwjVd1irahsBbg4k2sBwKDqJMUZVmR64KBv4oUv9bzBRnS/wUX
S1WYf9D/Rtk02Wo3Be26Pl8e3m6ay7fLw/X5ZnX/8NfLt/tnKbJb01D2gas4j7TkVq/X+88P
16ebt5fzw+XL5eEmylfRJFj8SLiyxCRYSDO02BHSmu4sRQ76Ln3kaEjH5wzvY5zh6wA18R5C
F7ddnNMPuyRGk0cuzkTaULMXTV++Pz+wsOvGyM3rRFFIGEWxdUNa1LiBaDzF1CnCoI7xRq0T
BtZMKIF1wr3wWKQlAkuD2RwIQ3Wkya5TWHm54T5J7Lmn2RjLjQqNa4hHDZ8i7Dlmfz4DC7Un
HEBf2suPVOo8ugdt8VgAaXi3dhJfbQtE9c3ctsXHEU0W01tZhOEL2iYRk+Wz68d9VN9Ob0tG
ee6quDeyFQiNSJj0exSwiY6K+DHWZ/URj7eAzxYR3/3LEpno3Ej6yQDykShgzHozzkspwhkC
XC2QaWFY5aGldXVOpl9mj7hvmfsanvQuPMP9R88QBP7S1HEYHC5cpZcws5iAIDqeWgVupUId
FE5oqH3U+q7h3onBabF27FVuHkCwalA+2REazH6EI/+egrsugqqFLMf0dVNLGW8bLbaIBKPB
iiw/zdgWiU0aEzNoky0C/6TFGGZQ7pGPBBl2exdCb9CmDtTQyJpEq5Nn6ROt+OldE4uHu0hr
sy7KXdeDvXQTR0kso7p1MqeGQUgdMfYJ7vK9nIxqr4zWQ7blSeeq3B7Zpq4EOBQosx9lwDzR
yTvOEZYsl4ZSM5NrIg9HtOkZqYoF9EhfklUQYIdIDKjq4tRjMM+Qx6LDXrbvb/JnPRbtTTGK
gANjdMx1luPOdgKXTH+Xux5pwcUlKRicy8WiXfEjNDylkFWHOvtUFpHhSTorYx4u9HkYDxvs
0/xnrrrA9icUku+Tns4Ny3uaeJmnklQz1Qng/ukP5a6NRJPIiQG9SOzZs4Oi2UsODCYePNxj
Z3si11jzia9fnojKTzxR3IahaPIgQInnypO8gBXwh/I+I7AoyqGAKGqcILdBSaIQx7bowjCM
GhuC3KMCtFdPujiaUKMuPbFkzW7pWpRyJ/HA/teOqPLDUPHFSUVAYGoNSDkxhJQGs1c90ZVB
jNRCBZY2dr1wSaaMBqyBTwsa9RKY72bTZrfKiyVVHwb5FpWtppsokGgbqUAeKaHJzJauh6Y+
UWzcju0fcIWkaYfAA5oRPRb6FZGoga7xCNh6/wnD+5EpHsLQ8g1DhYHh/JTAeJZ02secKo6m
BAmQojNNSOPkVWTZVHoINbS8Gi8PA5/sKIKipGGwgHq27zrUd4ISQmKOZCojY57lkA00aipG
TNZXFNQ2BNBV2EB7mW1JQT+hMUkJETDVTn6CxiWTKBNfhWdLNK6i00KN4QiGw1ztxGLzev/y
FQ+GNL8r0Ua4aoIfeKYupstIZLAmhohen3qCaFmDJMVlFJL6yHkSDaODyQR8zq3QDupX6Xqd
xWkp2JTyXemmFY4iD5sIlB/h1W9PwAkMFq1987vti1BzzFp87VxKZ8dJrbtthE3xzb+j758v
15v4Wr1eH85vb9fX3+DH85fL4/fXezwhEs/eIBH0gdp7stLSW7/eP51v/vz+5cv5tb9UEk6U
1kIVxrAY0O6C5f56BbtudFmfSrSibLP1nURKxL0J/GZXYIe0iYQbASFR+LfOdrs6jXUgLqs7
KEqkAVkO6tlql8nXMByr00NXgRq3Q9OPbnVHOvsDPthk0TkjQOaMgCnnqi6h76XdJm3x577I
o6pKUTdOadeLWG9Q2bNN0aUFdFoybEVfyrJqZBGn67SuIXXxxTgyQydTokGtsTPieYnBFz02
UBTfmnxz4Od4P8U9EMmlaLMdk0SbFWMUCKmffR3cBWlHmNhUWV2Ltn8ow1zaRHMKtNG67NAd
RFkU0FR0IeM72Ms4lrzHEOnYLU0CiGoyahkATbaDllHbOsublr7NABCawKY0MOwUOAqkGjOC
nHhBP9sAZLtReckwA0J3sBN+GCkLlU+S9Cd1dlAzQZLxWHXAzQGGBo5f9LIsEJ++ICGUX7b0
JJiADRGFV90uDS0voA0m8XM1rJA8SPAtrkEoUZKKxzEjST3QnQCytgSfJjeh87V3thMqIuDE
XwkTuKRuBr87ZZJD0mAWsYsTHTspFUPiL7JtXKW0jasOOwGLDtIWeyQRQu2BKI7NDdhkxgnu
YOrtRVrCdC5efQHx9q4ulXq4ydrQNQ5lmZSlLYnv0Ia+qHXiVFnD2lAoLVDfSr+r3JXXuajO
cbl90mmw2kd5lx7kaAoSGO+blnRICalw35k/VUonRrwaiRuaaEvUbJUDrV14onMJJnl2WiLR
8jEWsyzkfAViI6+WcI3CCGPNNk3VuTjal92tvTQc1rN+kVcG96iI5oHBzf7Y13F4UPqvxhfv
oqbRwk/CetDgCymx3LtyQ/olL/eFbDeJhK5sGvOtXFNIt0PctVOWUC6YtpnOyrz60ezM8SDp
ixnjM5TbOOtw8d+lvf4yVRlxTddjYSQwjsA2arptLNVzT14cszAQ7P6Hh7cCJubdedImRnr1
9efb5eH+283u/iftcpAltqXD3hRlxfBTnGYHkgNR7krG5LaLcUTJJtX3SKyA17+Z4v0NC/aT
+ZVqf76cP8RUWdu7Ko27fdzQN9mY1X5XZUYXYvsj/cIwz8mD1jRn8UOk09meZrqnZu6FmvfL
w19U+cev90UTrVP0J7DPdbeiYioYXhE3N4PTSMLgbUwVdhx5lxuisQxMf7AwnEXnhuRl9cBW
e0vhzKFIjyyUm3BnCr/4wJbG70jt1vA/5XOEsaxqnBgKjO64PeKz6WLDzABZtTAQl6YYs8/Y
sb2k/Axkf0FPVgwv0nYRkhMog491VGlpch8/1OEYg2WfVLwUeNO0IIjiwU5P9DzipcKIiW/X
JqJLEH1Hk/6uCj3D24wBDw0R2PrWSw/o+iijLEEn0YinTiMVD4pVQRq93vCvjrkiAOJ6gneZ
xAnlJwWM3F+5NwvTcx1e6db1DKemDCci6Ilwf56q1BjjwXlWoFJ3sbe0Tye9YaDzej/MZShb
pQrKYGCRVP/8dnn+69/2b2zurDermz5q3Xf0EXTToM0QTPa4Oo2eSOFH125hK5r/pgynFYvs
ocgZ72g0KaO9Wbg6kaVrXy+Pj8qUxCUBg3wDe2PqJAsUVrRVgl1kKxySpEmEbqtLNJ5o4nq/
UiDCchLp1MFdG3eS2zkk4LMnP7TDTjkKQIxNWkRCSR5xxUWY+yaael8mIIcBYnIBQD9dAiKo
CBvp6AhpvXc8xawkA8inHuOgkTeG/ZheOGT5Sg4E8hGDVG8xhS7f5C0FCEU44sexYvPeUzVC
7zF2rGWsus6MeIThU1+i6WAux+fxulYA9NV+PQQ3lczoMKF1tqPOraL9KcmaahcJ3QndceAW
TrSGTRaLgLxGyHIsapxl8q6vigrxLJX9HF1tWgq5LrF0v3symS9vsLQ2DW7s5KT5KeCA/etf
o44nmvHs0WVbtpYJVVIfcKeK3uyEGiKUwDLeQ5T6iO7DRAOzPQ9GFZfyPnXfOwLrd8OGlGBx
PWlf1XtyMCGWr31HOK8+rNFxIKyEe6bdCRtGRMT+wjiLkvGSsyhjyOnADrjf6g0QhYHMIx8M
Y/RweYUuR+ltfQgIkwVlD6/wTQr51KRn4DFynxRqnotNLRCHc+VumoC4enh5eL2+Xb+832xB
U379cLh5/H4GLZHa2YBIa1pz5xDazFQGLwpttMnEZzowVaRJpv5Wp8CRym1zYSjDTvNT2t2u
fnesRTjDlkcnkdNSWDEknd6EPbgqC2mc92R1gpHRYRj/1L7jYUhgPaYUwIGnOXRJURG5Zs1g
7EoNgiFzGFlDbZ4ULHQ8Tw7Y1ANRAv8Rr0gENMKEbct1iIIJDB5530Xw2f5cPp5496TDvnzG
qjE4Fqli63yO/E5bY3BtUnvT+Tzx4laH+aGwCuNDqsx3rJAsA0ODE+nsUmYKbVJcDFtyD/wm
LCSwA2J2IHpAUjFnDnNnMKqcPeYb0+wk49MBy6tdjAi+JiE7NWOoYsf153HfVd3TKxyZ49DB
ATU+MmZAzwW/2jQ21ieJGis0FCRpXWtuYCV3BfM8b1vkwNjADLetEnqVGabBtX+arWQWVx2G
a5xNJYk+Mn/ozmxx/6hNEr9FE659QcfoG+TITqlAXESnHzEi7R5LqLNpiSWf+z6fTSBPlZBB
Axklo5GLrPM9yc2eQCdmDKT7FtXCiASkE+CJYRetqtgg94ItHAlphiix5ETPrdvEc6h5tPEd
6mZuXHjblKoi6CmxaI0wLmwYysm4tkHrQLPZvhzHSRxaBFCwHtvh+z0zilPMwoBzmdIYU7V0
5OM+Yo8JIemKwmGR1vs1rtyEgNmC3sz0x1v+Fzemc/Pn3NxJS9MoDEOLCqYz7U4qDv+N7qWr
FgQWiy+mZay9zYzYMZWh0F466bB/zKBfv73fP16eH9XD7Ojh4fzt/Hp9Or+L1Of7b9dHDDjw
+fJ4eccoA9dn+Ex2LBwlsGZJloGc0mVrtEUFNRA0d/kCTUx9SPrPy4fPl9czf4NE59MGri2Z
R/Uk9ZqY6+j3L/cPkPLzw9lYA7HENnmMxgDhhBF+Bwt/PHdgBYY/PO3m5/P71/PbZRTgADz+
hC3Fw/XlDEk/v10nCRfn97+vr38xWfz8v/Prf26yp5fzZ1bomJSBt2Smf/x86PL49V1IcjrJ
b3bOj+CHLvIH5u8Sw1M8/rxhjY2dIYvFHNIg9OQwc5xESrk+v12/4fGZScSMazjEuvmAHfD5
MzQ8e8LXZ8AvxDz5Iv60Ga9gmpfz/V/fXzBhyO2Mj/fOD18FzxV8L8VtxoaPoufPr9fLZ6mV
m60pjm1miJmWbAraAmHTdOtqE+H5AnXQXzZSKPumVe3koyzvYno3jVAf/WNKY5vkMEvlQldE
inJnvanTO+V25n+6CuqTOYX+GD5B2B5PZY/x7TYZFwahbSKcpUQYIoUZdh1z6dgNw6zDXFnR
9uL/z9iTLDduJHt/X6HwyRMx9nCVxIMOhYUkmtiEAiiqLwi1mu5muCnqUVKM+339y6wqALVk
0Y4Yj5qZWQtqzczKRUWzDJLCaFmALxeymulgMKq0LXdPkMZ09BfVleKWtpkX6CqojSx+y+ZT
UvOG6KpDIvPKU0OZJWnRVstNkmoZSOpwjE79D3o26HUpbRQMSJdxUVswpSimG1nyxD+aJcsZ
L3I01BAkhlagZKkDxpyTA1B7TcZUlCrVHr35opiVLLo0Wqhi3yCNiP9BqFO6yJsR043W4jgu
Q6JPYvF5VrBAOYMnAocYo45rJsgKLRsODqc1wmUMrJPV0PBRRQlHV+WfAhmtpODrJNA0yArQ
BvWwOrQ6JXIN4+BpVBL49i9OVaYzMFI/Hq5rEVVlujSTtErleV4Dvz9pt7bHhEGFTyXxFu1R
rLq3uHssN1CM8mORlZntPof2H1WtKZA5y3gDN4E749ku886DrL5gGyf7mlXtvelqIqIBt6us
oSQOWWnFa3e4RIr40GtXWG5L4Rj/0/38pHTAwk1WRazJGr0x3lSSA6uKaRs0de2541T1TZ7U
2AD9wJ3uWnQJ7u8Fqt+ZfF7Snwgq4H77MtzGFNw9WzpEifEktbnufLSd9JwdIi0N/zgNDIwB
pV/vKGB86sJqaBNEeCEMZjYaPt1gAuW0KDDlz3DkYggawGGQA+B5Y+O4xPDjgOt4k/B0PAKX
G4pMYMJ2FbnA4QIeSrQ8mU/nRkQ0DRlGYXwz8giXPREXhqhh6alEeVX49BkdmZVVnCKRTiuX
eyOfpMnSO9piWSdJQo8HxPqBl0mOmc5cQUCMMj99nKmoBlAtrzAb52Q+NeY43tY2VPxsRZ5b
nTKAbdFRDmcD5umFDntC86xlHmI4av+GIKsbT/jGjqL2PNjEKgk2sMf0sYdWCAFpfCpfjJie
RUyChidi6YaBksTh+Uq+GpVP3/bvIo0dd7LhitJJsdUfQuEUlNyPc/YjNfFEK7uw9XDwGk33
7nEhMpkkXKZFWT62D73UUO2Pp/f96/n0TL1UVXFW1DGcF4Qg9Hp8c8RqDPnxK5f5S4sXkSn4
X0Pokcgk7mOT8FNoV3T4PdtZcO2Yz3dJy+mc4RgtodamEX9/Nq0CS8HjL6uYes2Md3hR3Q2Z
OTEKixMdzCAW4c4+MZEMeliMEuXhDxS2Zyams4WmcFFYjFk7Nb2AB4yIa0BvA0njPZsUvqpv
FzdTbXkqOM/m89HE6UxnmWdZrxXVI7XidGsmDAEfNMul7sM7wNowMMEb4YcASBOsrD/whiLq
kv/Uc/hpZRxS4SoMFy6eJYpkou0rfL5+UGIg/XGI70oePQql7liMdulUjz2tALZ3e5CxMWlI
EGTheD5S8s6RgpoxXyI2uTWUshGbkp4OeBxFI835VQBMZwDxrbVqZsp2ZJL4zY5HC31dCIDX
lWGzCz9txqMxvXozuPCmtOlVlrGb2Xzu82MH7LXuoAiAW/SC/GnUsJjP6Ztf4kgn/l04G+lp
twBwLRWz3SFTb26nugshAgKmBSD9p4rFycJgfQCyWNAm1yrejy+3hMo7xEi3gDAEkXo0bmV4
C22lYJwd2Oa+Ste7G3IpyaDAZgASDPY9uzW01wLkC4zCduMpHQGI7RbXuhMsBuSfTfSoEXHe
fh7Lr9Xby1mD8dRJUR8PR/mlmpyJL4/h6HZsjIqAimjLREVDtBCr7S7kROYbSxFxYkqMtlww
x9cfcGdqN2L4fX8Upte8V3/2nFcK31KulU7A2L/s3hPRYvv5drGzTkYlHuiZODSR1KXozr71
4avqlVC5S2Zf44XQAIUPcaKFCk+yC7zsClKFMIaYUYjGKRFZCRofL7oitlNIw857knvQpw+f
j67pd1AM/0CezICYzSz1/Hy+mJJvmGhGxfRQGteT6dQ8nNhuTvoxw3qf3Uz6xKo4xF8/jsef
ijfqPnV53v/vx/7l+Wevlv8/1EBHEf9Pmab9MhLCwapL2Pyf6PD2fj58+VB+rjLM3/ent/1v
KRDuv16lp9Pr1a9Qw7+u/uhbeNNa+Ce6//7WWo31537524pZVjbT0XzkAOwLUy2C1WNVuDfT
QFWvppQd7Hr/9OP9u7aXOuj5/ap6et9fZaeXw7v1ysCW8WxGZgJEVm1kpUNSsInb9sfx8PXw
/pN6yGDZZEoeNNG61g061hEe4doGXtd8oht6y9/m0K5BtNJzIyQ3eK0Zvyf9lZXACnlH69/j
/unt47w/7l/erz5gUIz5TKz5TJz53GS7a+3wTvItzui1mFH9fdBA6BWoiU55dh3xnXMKKLh+
rNjPRN3YoqqPpRqTyKJPUcunZgB2lsLGHFGPq6yM+GJqzrKALTwW8MF6fEO+siFCz34YZtPJ
2Ex7iCDamgnum8nUIr2mk+3ph7Z0niqtTKircsJKmHY2GtH+nv0JzNPJYkRmwTVJJtojsYCM
Jxrv9Imz8cSItlBWo7kZZj+tK5/PAWyq2Wzksc0vSrSXoQuWDDNAedE8GY9nZBj7ejOdGgHg
Qz7FZHcm4IbOTgCfPyeZGoHRXQAAMJtPtd3Z8Pn4dqLZQ2zDPDWtTLZxBjzEjbEet+m1JUdI
I8+nby/7dymdEDtjA7KgNklsM1osdJZLiRsZW+V3tgyCQOsIZ6upETQ/A65+PpmNnE0tyorT
29nXXbU2un/4yMK5EdrPQugHgoj3+fpj/5d2XSUvzz8OL86I/JPnW5HUrFLKqF4M1JAo11dV
U9a0CFrjTkyLoqRLi1DlWknjdn09vcNBfBjkzIF75zDxJAMN/MNcz4RYl+lI5tMgq4ZP1g/5
NCsXY+nxL7mD8/4NLwRiGQXl6HqUrfR1U06MLK/it8vNdWdUwCrtSliXevLSrEzHY10KE7+t
AGVlOh2PtTst4/Nr/d6Uv63lCrDpjbMAyyrm7rIUULPRei6z3/S9noyuDVblc8ngKL92NqW4
p17QIMFaf+X59NfhiCwCvlp/PbxJqw5nwNMkwte0pI7brZ42qlqO9OxIu4XhL4zo227y6/3x
FVlBckKzdLcYXRuHXVaORgbPKyC0TFfDSibDOQrERHOLyOvAENzqoE18gawBVyb5qixyOhAC
EtRFQT1ribJxpb3WC+KK5VxoeYeTNYvR67M35c/iq+B8+PqNzBCAxCGIzuFuRt3XiK7hfpkZ
IeQQumQb11tTtHV6On+lm0qw4I0VVbUv6FNUYiHhiWX1oEwKUjzW3ejghzySTJDMzm0ArEDD
COzjZRow/Z25g5i2ugNUPaWZKOEdeDs3OwAStQNoZT6I7oCqsnaVhCJsUF7djTU5oWThxnb0
7TgUTNMtzHirIk3tIIOIY/X6ZkEuRokP4ipN6LdISbCKsySnHy0kQZLt6D0m0WkZji2XVIsi
i7nnNVTiy4TXLFx74/8hDS9CNAG6RFFn3ohdAo+q+wv4OlExWS/QfH7M7y9VEa8q1galJzXT
MnOVLeivzj++vIl3i2HTdGE7AK3dYGHWbjAIZ8ODiUANC3P9iG967eQ2z9o11x+0DRSWNN4j
ABnCii5t//yBQmSVYZTFRBYavoeZtFamCcWLcXeL789/nM5Hca8cpazrxharmJV5qMmjuAqK
1HWzG6zPur2WR1WhR7ZSgDZIsBLzZd/CdSZYv3w5oCPqv7//V/7jF39d7XQSJNqjdcQ0UTGH
s05Pfltrxwn8aKMmyx5NEC+aSgUWLVLDAkTDrmNW1UHMyCwb4m2nXttGHfXatsXu4aua8nDv
0ZysLOMNWVnpeQTtCeiQA2KDG9HPtMfNYRdZx4AsyhN3CQHQsBPjCZy+vL4UuF+jWTf0hkAS
OCboh1HhrVCm8c70JpB9PJyPIlSW+5YXabIW/GiLpfYE1Udrg4WUMcOyQNnDUQG7ozAKmOHp
m+g7An6qm/VogEKWixwg6KyXF3kbLxPgFdIUbTOMV2IewjgkwbKG/uVUBJHlQxsuV/b1rUPd
aHOrolilcf/FeoMKhQpX4WcqM5R5LNQUMQxYt4nsJgaUsMBM4xULH43nziW69GHeDFzQrOLE
jNb7b+enqz+6ebV0oge0nhXnuu4oHcLgxu1DUUXKdVwbG0wXzZMdIDRuIt4hf7g0TsMO1gZo
INEWJRkdLIGPQ7x0fdT0GHmEUQkeDQqqAuCpcmHsnhihsbgdETCyAYkEOHzfkkkE0dh9U9SG
U7UAoG0uuvZLsRYtrOhLqgK8KgELJ6e/R+ItJ08JrKtYe2+4X2Z1u9WkVgnQNEeiVFhr08Sa
uljyWWssdvj+1py5sOHUk0ixBTaNPRqlBxiwF1GCMQxb+KPXppHgbeRGNQifnr8bUSC5WH/G
nEgQGnbXnvBaimKNaYdXtO1DR9ONrlO4CD7hB6QJ4Sdfvu0/vp5gI/3YOxsGDUCsMRSgjedx
SSCRkdMnRwDRObjNijwxInIIFJx3aVTF2iLfxFWuT4Z1jIHk6fykNq9E7Fhda02umxWs6kCv
QIFEHzXVrPgDFZjfL9yHce9Cp+rYEyVHGbX76DoqXSUNPzprnrtfDm+n29v54rfxLzo6LKJY
jONsamSoNnA3U1peMIluKJWnQXKreylYmIkXM/dibvRBNHHXlKbcIhlfKE4LHhYRbXVgEVFP
PBaJpmOyMNcXukhl1jVIFrrjlYnxTsRiOvGVmS183byZmZiEF7jU2ltPI+OJt31AjU2UCHxB
129RduCJPWgdglJo6vgZXd+cbv2apr6hqRc09Xjq6+yYfkE2SOh0OEiyKZLblk5A2qMpLhOR
GDmlKoCrML9ExF2JgR0OKThc501VmB8pMFXBahlpzuiBwD1WSZomtE1DR7Ri8d+SwGW/ufAx
IP+lzIzS16PyJiGz2OnjkLDcPhsRVzfVJiEDiSFFUy9vOwF5sz+/7H9cfX96/vPw8m24C+sK
TcyT6n6ZshW3DURfz4eX9z+l2va4f/umxZ3R2aSNsFQ1LhnBBqfIF2/jPp/u3U0vvsuQLi7F
THtuRJ5c1S9yD5MzgE7jIs8XKf+Fp+MrsAC/YTK+K+Bbnv98E1/zLOFnKpCOqAmmZUmaOoqk
rIIjBMISOChW6zo5hc8aXgMLEOumxktgc2TJu/FoMhvE8yop4YxBtWRmXMpVzCIpknCKP2py
YPww608WFKnJzeDQFg856X8uP8/gFKAdtCDs+muNBAcmK0EzzYRnGFzD865qEskRKvKUYsxF
QMcHBvy1HJOyELw4t8dKwTWpQPa9QG3FQ8w2wugxLPV0RBiYFVmr6p4E9rbFcqLuRn+NKSoZ
4sRuGDk44ab1P0Mgwqto/+Xj2zdjU4nxj3d1nHNDzJG1IFYkaHaHukd160j11vMGvBJDhE5e
pHAi66wKEM2YCPZi90Qy0NwDhkFIlxeKwSTFsQ8nnhO9NSvfSOvrO2wVNmJN0vvdIIX5h+m/
EG3BJDdH9a6feuH8oeYYxPgUlpbbvQ7jbQVVzhsQUCXDbZXeUlu4j2yqaFTcW7ewRHhblqbL
cGbpOkMFFOJxAvskrirMZpN/MiLXywrWyWptKBW1ERGfhWLhMi0e7IIepCguvg5HzXewrK0Q
XPL9FvfTFZprfbzKw3r99PLNSWKNOoamhJpq+BxPonN0NbpA13cGUSAv5XAdMr7RP1GeFT2q
VelP78aTkXlRoZt8phGWnoyrXtp2y9ImHoKmPdwTSYwlJRyzhRHb3wCrisYmsut4Xz+HSYlc
2VqC7cvPRPvFella7oM4j+SNcmEbY682cVxa55d8TkbLvv5wvfr17fXwgtZ+b/++On687//a
wz/278+///67FrlRHXk1XMB1vIudA6jzMrLhHvKHB4lpOaxuVNvZBEJX1h3mPUsE+0HTkikw
AoBj0AdblMbR9G7soZAB7qJAprGLUw2j+09/gnOzGy1sBGAdY3kp6Cne++9VBanXboNj1J8h
YNYFUv9EwQbAAGFQ3ziOYHW4qUbsc1ae1n9P0aKTLyOVX5IO/tviAw8nzmNba2TfxMnfUXD/
ldsduc56CqsYA7on0mxPOh6FDclCiEUESE3xo09aD8XLEo0AurnUwFaBga9EXMVIdxDExffc
PRjUhrhX3Fcl+C5K8KCuG4MLKjPPnaQLOHGNmnKSjlYoioO6b42kSYFVz8NH2lcb9craGnYj
kYsrbdnkks8VRJUPu6pYuaZpOnll2W0VP7J9SOo1hvzldjsSnQm2BwjCooosElRX4rYTlIKP
tisJVUFZi7bMoASeH0Q42aWzauQS/ngR8lW9f3uXi3h4Y425VNDCnU3GwRcE3GonGGYBziEn
TuGwkANUsvvxQnqA67AlybrlKFlIc/vIA/Z6NvDAR+uj1vEuajyv8vKjQK7LV10KHN+nb4Cs
LrQgWQIqpN6l02aQ1Bn5bC6wTZNEVj0V8JZry0dT9h7g2lO/ykKE0fnH08VMxNlVzORwAGDs
3TK5kLNFTvaGYnRlB3GLYYokq5dBubQg/WudPQJSC+9tQKgJDKv1OPNdY3KOWA3bbRM/GqHS
hMgA8j3KTbBF0PTRd6ZwjDFFZtLRWOBVZFg14O9LwkATcJZDzTABGPGTmREieuG5I8yLNm9S
alAEXi/r1kx+lCRjabLKM7iuLtB4GtbkGrRVaBMumKQHXVOCb6TqdhZccWOwRjGr0kel/SHb
F0FuatyCrTfLxUBz4R5/oO2MoqKBbeOXvhUDmwbLtCE1cMrduTbtLsWqwPi1nlsGHWtwEYt4
v+1odzsaWHYbB6M5pnFqI0xobF7k8d1UOyY7LDZHH6QDRUw9zPd41fBPoii2SnJM6urWuzj0
XDFyQhWIYpP58lleSiFVwK7NcJkDy59cVJHAGq8ebV4tzxJCA4JLSmmhSsPHXcbfwHvDo4rk
++ePMxrBOjpUcfz81O4jDhcm9AkReIdoyMAhr6sGiCMLqh7ZO7h2tsHvNlpjDrCK4alGHV08
DpsqqR8xVDYXlmhwl+lKg47AkBy7Qg/w/0LNsi6KzaXqjcfQrrQTOcvGtLtllRFoJZ7ZlkE7
D78Iuw7NCaTpE320y8sBby1MZicvcp/yU/YBZr94JHP0dBSshGWc6a/FDkrTEViivEsq7nFq
EgwKSo3oLeCqBGiSlnEYGZ8iwFNG6f3/ptAjy2izTJzTFZJcOEioodZObYuITpBgk9398vT6
+nQ+ngabPRmxsZPiwvPP1/fT1fPpvL86na++73+8CrMdgxjuwJURlMMAT1x4zCIS6JIG6SZM
yrUubdgYt5BaPC7QJa2MUOc9jCTs1atO17096TB6VCCB2JQlQY2xyIimRZbE4XKQ0Ii6mxUu
DiN3ADKWsxUxkApuPO0qVMPpSL9GQUxGKY5FSyGjqFbL8eQ2a1IHgSwWCXRHAI/H+yZuYgcj
/kRE1zOJ8feeNfUabhOiKJmfgn28f0e3m+en9/3Xq/jlGTcGml3+9/D+/Yq9vZ2eDwIVPb0/
ORskDDOioVVIiRRdkTWD/01GZZE+jqe6A6gi4PF9siVqjaEYsAVb5xMC4VN8PH3VrZy61oLQ
HdvaXSwhMcOxHhtEwdLqgehaCc34v3hH1A23ukjUpI6j9dPbd98XZMz9hDUF3OHHuhtqmzHX
5jw6fAPh322sCqcTqhKJcHNrElTE+Ag4jFIK+4W8Jwa6ejyKkqW/iZUpCXcT4FtMWTQjYARd
AqsL2I8scce1yiLM0Ol+FiJIq6EBP5lfU/VNjUj2at2v2dihBaCswm4bEPMx6Z/b46dObfWq
Gi+IY6iEqvqb8fD63YzY1d1j7ioGGEY7cpcLIua315fmGkny5EK21o4ubwIy7kuHr8KZ07EA
ZNdlQtyWHaLt05U5a5BlcZqSqUR7CrQV8JfnNWXWpqGp+fQlblbopfjrr3azZp9ZRMwEZyln
dDYJgwCnyz0V1VlNrb/YE761x1elTxVhkrTAlk7s1WLfXBSnANLFkjamMQmGuaLR8st78xP0
Lz3osUD6GVqiQproSPqZDGAvkbczd8Oln90lC7B17x5TPb18PR2v8o/jl/25C5dBdYrlPAGx
mmL3oioQsWkaGqOuEGcdChyd7FAnoS5RRDjAT0ldxxVK7KhItLFCxUjx2B3CkZhsPFes6KWV
1hNXHqdNm45Z1gwuyy2eXIl+rR8o9Rp/zDAfrlRdSo3JTwJZNkGqaHgTCLL+ltjNR4s2jFEK
TtCGSTkkaErhTchvekOtHivXNQbT+EMweW8i897b4duL9LoVRlbWK4A0FtZVFRWtjlGEQSrC
dvJeA6JJyzaFGDz8l5YeTCjZNltNS6AMKJLPTL1FDfoQ0jBjuy7wUK4wia7MU0v4cwRJziql
pFw6LFF6+HJ+Ov+8Op8+3g8vOicWJHUVY/oH41ly0BcPeOqBTnyBbpvUOfbxusrD8rFdVsX/
93Ut2xGCMPSbpmdO96LMlBbFQTydsuEL+v/bJlFromGW3kTwmRDy6rc0CYXF26FCHWwqc3I8
fnsjYUIO7sovTogzHdvBuLCkEh1IVZh9stt28Q1V4Zrw5KQN1oJxAL++gC4HzdeWF8s9mDLN
JfF10rK65Ieqv2elwK9kzY9WMUQwXA/XhJQmfsMvVhEVyGHUENAW1yLyQvQweO/MsqLWB2FR
0M3cubS9BOFWIAK9iaXUt9bZbve8kROfPS9lYtBUNJTcAEe0s2c8YxsMEIJ+aXrN0V1Tbreb
gzoG6DxlRtKEOq6O8swIH49x55c/rxWlXNZRe+4rg2ver8p5jVqCeSemj7k3ynkTCOIXs5n2
83ThxxC+7Y7LPbtRJRggvKkUn0UvzJ3wzBX+UMGvZ5FAcTSyuW20GE8UfMAF16+G4qgXttQ0
LTPnDH3Nw8ScByslWTCjLX7uGla++lHFTa/Ct4nhzTSF1oGYJnkeec9NlHEgD2WgHULoBCpC
TpL37NQTtAxYZyVUasMjA/Vy1LP3ugfTGoOXGUStz5gAyYAQO269dp3YSXXxgWayZr33o2zV
g6nN0d5BR0fhnJ0wHsvXSixjnrha9uJfWwAL7eEoioQ6RJJnDoh/AjKk8dV2AQA=

--ReaqsoxgOBHFXBhH--

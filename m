From: Julien Fortin <julien@cumulusnetworks.com>
Subject: [PATCH 05/27] ip: ipaddress.c: add support for json output
Date: Thu,  3 Aug 2017 17:54:53 +0200
Message-ID: <20170803155515.99226-6-julien@cumulusnetworks.com>
References: <20170803155515.99226-1-julien@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        dsa@cumulusnetworks.com, Julien Fortin <julien@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f175.google.com ([209.85.128.175]:37978 "EHLO
        mail-wr0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751857AbdHCPzl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 11:55:41 -0400
Received: by mail-wr0-f175.google.com with SMTP id f21so7355944wrf.5
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 08:55:40 -0700 (PDT)
In-Reply-To: <20170803155515.99226-1-julien@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Fortin <julien@cumulusnetworks.com>

This patch converts all output (mostly fprintfs) to the new ip_print api
which handle both regular and json output.
Initialize a json_writer and open an array object if -json was specified.
Note that the JSON attribute naming follows the NETLINK_ATTRIBUTE naming.

In many places throughout the code, IP, matches integer values with
hardcoded strings tables, such as link mode, link operstate or link
family.
In JSON context, this will result in a named string field. In the
very unlikely event that the requested index is out of bound, IP
displays the raw integer value. For JSON context this result in
having a different integer field example bellow:

if (mode >= ARRAY_SIZE(link_modes))
	print_int(PRINT_ANY, "linkmode_index", "mode %d ", mode);
else
	print_string(PRINT_ANY, "linkmode", "mode %s ",
		     link_modes[mode]);

The "_index" suffix is open to discussion and it is something that I came
up with. The bottom line is that you can't have a string field that may
become an int field in specific cases. Programs written in strongly type
languages (like C) might break if they are expecting a string value and
got an integer instead. We don't want to confuse anybody or make the code
even more complicated handling these specifics cases.
Hence the extra "_index" field that is easy to check for and deal with.

JSON schema, followed by live example:

Live config used:
$ ip link add dev vxlan42 type vxlan id 42
$ ip link add dev bond0 type bond
$ ip link add name swp1.50 link swp1 type vlan id 50
$ ip link add dev br0 type bridge
$ ip link set dev vxlan42 master br0
$ ip link set dev bond0 master br0
$ ip link set dev swp1.50 master br0
$ ip link set dev br0 up

$ ip -d link show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode
DEFAULT group default
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00 promiscuity 0
addrgenmode eui64
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UP mode DEFAULT group default qlen 1000
    link/ether 08:00:27:db:31:88 brd ff:ff:ff:ff:ff:ff promiscuity 0
addrgenmode eui64
3: swp1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode
DEFAULT group default qlen 1000
    link/ether 08:00:27:5b:b1:75 brd ff:ff:ff:ff:ff:ff promiscuity 0
addrgenmode eui64
10: vxlan42: <BROADCAST,MULTICAST> mtu 1500 qdisc noop master br0 state
DOWN mode DEFAULT group default
    link/ether 4a:d9:91:42:a2:d2 brd ff:ff:ff:ff:ff:ff promiscuity 1
    vxlan id 42 srcport 0 0 dstport 8472 ageing 300
    bridge_slave state disabled priority 8 cost 100 hairpin off guard off
root_block off fastleave off learning on flood on port_id 0x8001 port_no
0x1 designated_port 32769 designated_cost 0 designated_bridge
8000.8:0:27:5b:b1:75 designated_root 8000.8:0:27:5b:b1:75 hold_timer
0.00 message_age_timer    0.00 forward_delay_timer    0.00
topology_change_ack 0 config_pending 0 proxy_arp off proxy_arp_wifi off
mcast_router 1 mcast_fast_leave off mcast_flood on neigh_suppress off
addrgenmode eui64
11: bond0: <BROADCAST,MULTICAST,MASTER> mtu 1500 qdisc noop master br0
state DOWN mode DEFAULT group default
    link/ether e2:aa:7b:17:c5:14 brd ff:ff:ff:ff:ff:ff promiscuity 1
    bond mode 802.3ad miimon 100 updelay 0 downdelay 0 use_carrier 1
arp_interval 0 arp_validate none arp_all_targets any primary_reselect
always fail_over_mac none xmit_hash_policy layer3+4 resend_igmp 1
num_grat_arp 1 all_slaves_active 0 min_links 1 lp_interval 1
packets_per_slave 1 lacp_rate fast ad_select stable ad_actor_sys_prio
65535 ad_user_port_key 0 ad_actor_system 00:00:00:00:00:00
    bridge_slave state disabled priority 8 cost 100 hairpin off guard off
root_block off fastleave off learning on flood on port_id 0x8002 port_no
0x2 designated_port 32770 designated_cost 0 designated_bridge
8000.8:0:27:5b:b1:75 designated_root 8000.8:0:27:5b:b1:75 hold_timer
0.00 message_age_timer    0.00 forward_delay_timer    0.00
topology_change_ack 0 config_pending 0 proxy_arp off proxy_arp_wifi off
mcast_router 1 mcast_fast_leave off mcast_flood on neigh_suppress off
addrgenmode eui64
12: swp1.50@swp1: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop master
br0 state DOWN mode DEFAULT group default
    link/ether 08:00:27:5b:b1:75 brd ff:ff:ff:ff:ff:ff promiscuity 1
    vlan protocol 802.1Q id 50 <REORDER_HDR>
    bridge_slave state disabled priority 8 cost 100 hairpin off guard off
root_block off fastleave off learning on flood on port_id 0x8003 port_no
0x3 designated_port 32771 designated_cost 0 designated_bridge
8000.8:0:27:5b:b1:75 designated_root 8000.8:0:27:5b:b1:75 hold_timer
0.00 message_age_timer    0.00 forward_delay_timer    0.00
topology_change_ack 0 config_pending 0 proxy_arp off proxy_arp_wifi off
mcast_router 1 mcast_fast_leave off mcast_flood on neigh_suppress off
addrgenmode eui64
13: br0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state
DOWN mode DEFAULT group default
    link/ether 08:00:27:5b:b1:75 brd ff:ff:ff:ff:ff:ff promiscuity 0
    bridge forward_delay 1500 hello_time 200 max_age 2000 ageing_time
30000 stp_state 0 priority 32768 vlan_filtering 0 vlan_protocol 802.1Q
bridge_id 8000.8:0:27:5b:b1:75 designated_root 8000.8:0:27:5b:b1:75
root_port 0 root_path_cost 0 topology_change 0 topology_change_detected 0
hello_timer    0.00 tcn_timer    0.00 topology_change_timer    0.00
gc_timer  244.44 vlan_default_pvid 1 vlan_stats_enabled 0 group_fwd_mask 0
group_address 01:80:c2:00:00:00 mcast_snooping 1 mcast_router 1
mcast_query_use_ifaddr 0 mcast_querier 0 mcast_hash_elasticity 4096
mcast_hash_max 4096 mcast_last_member_count 2 mcast_startup_query_count 2
mcast_last_member_interval 100 mcast_membership_interval 26000
mcast_querier_interval 25500 mcast_query_interval 12500
mcast_query_response_interval 1000 mcast_startup_query_interval 3125
mcast_stats_enabled 0 mcast_igmp_version 2 mcast_mld_version 1
nf_call_iptables 0 nf_call_ip6tables 0 nf_call_arptables 0 addrgenmode
eui64

// Schema for: ip -brief link show
[
    {
        "deleted": {
            "type": "bool",
            "attr": "RTM_DELLINK"
        },
        "link": {
            "type": "string",
            "attr": "IFLA_LINK"
        },
        "ifname": {
            "type": "string",
            "attr": "IFNAME"
        },
        "operstate": {
            "type": "string",
            "attr": "IFLA_OPERSTATE",
            "mutually_exclusive": {
                "operstate_index": {
                    "type": "uint",
                    "comment": "if state >= ARRAY_SIZE(oper_states)"
                }
            }
        },
        "address": {
            "type": "string",
            "attr": "IFLA_ADDRESS"
        },
        "flags": {
            "type": "array",
            "attr": "IFF_LOOPBACK, IFF_BROADCAST...IFF_*"
        },
        "addr_info": {
            "type": "array",
            "array": [
                {
                    "deleted": {
                        "type": "bool",
                        "attr": "RTM_DELADDR"
                    },
                    "family": {
                        "type": "string",
                        "attr": "ifa->ifa_family",
                        "mutually_exclusive": {
                            "family_index": {
                                "type": "uint",
                                "comment": "if family is not known"
                            }
                        }
                    },
                    "local": {
                        "type": "string",
                        "attr": "IFA_LOCAL"
                    },
                    "address": {
                        "type": "string",
                        "attr": "IFLA_LOCAL && IFA_ADDRESS"
                    },
                    "prefixlen": {
                        "type": "int",
                        "attr": "IFLA_LOCAL"
                    }
                }
            ]
        }
    }
]

$ ip -json -brief link show
[{
        "ifname": "lo",
        "operstate": "UNKNOWN",
        "address": "00:00:00:00:00:00",
        "flags": ["LOOPBACK","UP","LOWER_UP"]
    },{
        "ifname": "eth0",
        "operstate": "UP",
        "address": "08:00:27:db:31:88",
        "flags": ["BROADCAST","MULTICAST","UP","LOWER_UP"]
    },{
        "ifname": "swp1",
        "operstate": "DOWN",
        "address": "08:00:27:5b:b1:75",
        "flags": ["BROADCAST","MULTICAST"]
    },{
        "ifname": "vxlan42",
        "operstate": "DOWN",
        "address": "4a:d9:91:42:a2:d2",
        "flags": ["BROADCAST","MULTICAST"]
    },{
        "ifname": "bond0",
        "operstate": "DOWN",
        "address": "e2:aa:7b:17:c5:14",
        "flags": ["BROADCAST","MULTICAST","MASTER"]
    },{
        "link": "swp1",
        "ifname": "swp1.50",
        "operstate": "DOWN",
        "address": "08:00:27:5b:b1:75",
        "flags": ["BROADCAST","MULTICAST","M-DOWN"]
    },{
        "ifname": "br0",
        "operstate": "DOWN",
        "address": "08:00:27:5b:b1:75",
        "flags": ["NO-CARRIER","BROADCAST","MULTICAST","UP"]
    }
]

Schema for normal plus -details: ip -json -details link show

[
    {
        "deleted": {
            "type": "bool",
            "attr": "RTM_DELLINK"
        },
        "ifindex": {
            "type": "int"
        },
        "ifname": {
            "type": "string",
            "attr": "IFLA_IFNAME"
        },
        "link": {
            "type": "string",
            "attr": "IFLA_LINK",
            "mutually_exclusive": {
                "link_index": {
                    "type": "int",
                    "comment": "if IFLA_LINK_NETNSID exists"
                }
            }
        },
        "flags": {
            "type": "array",
            "attr": "IFF_LOOPBACK, IFF_BROADCAST...IFF_*"
        },
        "mtu": {
            "type": "int",
            "attr": "IFLA_MTU"
        },
        "xdp": {
            "type": "object",
            "attr": "IFLA_XDP",
            "object": {
                "mode": {
                    "type": "utin",
                    "attr": "IFLA_XDP_ATTACHED"
                },
                "prog_id": {
                    "type": "uint",
                    "attr": "IFLA_XDP_PROG_ID"
                }
            }
        },
        "qdisc": {
            "type": "string",
            "attr": "IFLA_QDISC"
        },
        "master": {
            "type": "string",
            "attr": "IFLA_MASTER"
        },
        "operstate": {
            "type": "string",
            "attr": "IFLA_OPERSTATE",
            "mutually_exclusive": {
                "operstate_index": {
                    "type": "uint",
                    "comment": "if state >= ARRAY_SIZE(oper_states)"
                }
            }
        },
        "linkmode": {
            "type": "string",
            "attr": "IFLA_LINKMODE",
            "mutually_exclusive": {
                "linkmode_index": {
                    "type": "uint",
                    "comment": "if mode >= ARRAY_SIZE(link_modes)"
                }
            }
        },
        "group": {
            "type": "string",
            "attr": "IFLA_GROUP"
        },
        "txqlen": {
            "type": "int",
            "attr": "IFLA_TXQLEN"
        },
        "event": {
            "type": "string",
            "attr": "IFLA_EVENT",
            "mutually_exclusive": {
                "event_index": {
                    "type": "uint",
                    "attr": "IFLA_OPERSTATE",
                    "comment": "if event >= ARRAY_SIZE(link_events)"
                }
            }
        },
        "link_type": {
            "type": "string",
            "attr": "ifi_type"
        },
        "address": {
            "type": "string",
            "attr": "IFLA_ADDRESS"
        },
        "link_pointtopoint": {
            "type": "bool",
            "attr": "IFF_POINTOPOINT"
        },
        "broadcast": {
            "type": "string",
            "attr": "IFLA_BROADCAST"
        },
        "link_netnsid": {
            "type": "int",
            "attr": "IFLA_LINK_NETNSID"
        },
        "proto_down": {
            "type": "bool",
            "attr": "IFLA_PROTO_DOWN"
        },

        //
        // if -details
        //

        "promiscuity": {
            "type": "uint",
            "attr": "IFLA_PROMISCUITY"
        },
        "linkinfo": {
            "type": "dict",
            "attr": "IFLA_LINKINFO",
            "dict": {
                "info_kind": {
                    "type": "string",
                    "attr": "IFLA_INFO_KIND"
                },
                "info_data": {
                    "type": "dict",
                    "attr": "IFLA_INFO_DATA",
                    "dict": {}
                },
                "info_xstats": {
                    "type": "dict",
                    "attr": "IFLA_INFO_XSTATS",
                    "dict": {}
                },
                "info_slave_data": {
                    "type": "dict",
                    "attr": "IFLA_INFO_SLAVE_DATA",
                    "dict": {}
                }
            }
        },
        "inet6_addr_gen_mode": {
            "type": "string",
            "attr": "IFLA_INET6_ADDR_GEN_MODE"
        },
        "num_tx_queues": {
            "type": "uint",
            "attr": "IFLA_NUM_TX_QUEUES"
        },
        "num_rx_queues": {
            "type": "uint",
            "attr": "IFLA_NUM_RX_QUEUES"
        },
        "gso_max_size": {
            "type": "uint",
            "attr": "IFLA_GSO_MAX_SIZE"
        },
        "gso_max_segs": {
            "type": "uint",
            "attr": "IFLA_GSO_MAX_SEGS"
        },
        "phys_port_name": {
            "type": "string",
            "attr": "IFLA_PHYS_PORT_NAME"
        },
        "phys_port_id": {
            "type": "string",
            "attr": "IFLA_PHYS_PORT_ID"
        },
        "phys_switch_id": {
            "type": "string",
            "attr": "IFLA_PHYS_SWITCH_ID"
        },
        "ifalias": {
            "type": "string",
            "attr": "IFLA_IFALIAS"
        },
        "stats": {
            "type": "dict",
            "attr": "IFLA_STATS",
            "dict": {
                "rx": {
                    "type": "dict",
                    "dict": {
                        "bytes": {
                            "type": "uint"
                        },
                        "packets": {
                            "type": "uint"
                        },
                        "errors": {
                            "type": "uint"
                        },
                        "dropped": {
                            "type": "uint"
                        },
                        "over_errors": {
                            "type": "uint"
                        },
                        "multicast": {
                            "type": "uint"
                        },
                        "compressed": {
                            "type": "uint"
                        },
                        "length_errors": {
                            "type": "uint"
                        },
                        "crc_errors": {
                            "type": "uint"
                        },
                        "frame_errors": {
                            "type": "uint"
                        },
                        "fifo_errors": {
                            "type": "uint"
                        },
                        "missed_errors": {
                            "type": "uint"
                        },
                        "nohandler": {
                            "type": "uint"
                        }
                    }
                },
                "tx": {
                    "type": "dict",
                    "dict": {
                        "bytes": {
                            "type": "uint"
                        },
                        "packets": {
                            "type": "uint"
                        },
                        "errors": {
                            "type": "uint"
                        },
                        "dropped": {
                            "type": "uint"
                        },
                        "carrier_errors": {
                            "type": "uint"
                        },
                        "collisions": {
                            "type": "uint"
                        },
                        "compressed": {
                            "type": "uint"
                        },
                        "aborted_errors": {
                            "type": "uint"
                        },
                        "fifo_errors": {
                            "type": "uint"
                        },
                        "window_errors": {
                            "type": "uint"
                        },
                        "heartbeat_errors": {
                            "type": "uint"
                        },
                        "carrier_changes": {
                            "type": "uint"
                        }
                    }
                }
            }
        },
        "stats64": {
            "type": "dict",
            "attr": "IFLA_STATS64",
            "dict": {
                "rx": {
                    "type": "dict",
                    "dict": {
                        "bytes": {
                            "type": "uint"
                        },
                        "packets": {
                            "type": "uint"
                        },
                        "errors": {
                            "type": "uint"
                        },
                        "dropped": {
                            "type": "uint"
                        },
                        "over_errors": {
                            "type": "uint"
                        },
                        "multicast": {
                            "type": "uint"
                        },
                        "compressed": {
                            "type": "uint"
                        },
                        "length_errors": {
                            "type": "uint"
                        },
                        "crc_errors": {
                            "type": "uint"
                        },
                        "frame_errors": {
                            "type": "uint"
                        },
                        "fifo_errors": {
                            "type": "uint"
                        },
                        "missed_errors": {
                            "type": "uint"
                        },
                        "nohandler": {
                            "type": "uint"
                        }
                    }
                },
                "tx": {
                    "type": "dict",
                    "dict": {
                        "bytes": {
                            "type": "uint"
                        },
                        "packets": {
                            "type": "uint"
                        },
                        "errors": {
                            "type": "uint"
                        },
                        "dropped": {
                            "type": "uint"
                        },
                        "carrier_errors": {
                            "type": "uint"
                        },
                        "collisions": {
                            "type": "uint"
                        },
                        "compressed": {
                            "type": "uint"
                        },
                        "aborted_errors": {
                            "type": "uint"
                        },
                        "fifo_errors": {
                            "type": "uint"
                        },
                        "window_errors": {
                            "type": "uint"
                        },
                        "heartbeat_errors": {
                            "type": "uint"
                        },
                        "carrier_changes": {
                            "type": "uint"
                        }
                    }
                }
            }
        },
        "vfinfo_list": {
            "type": "array",
            "attr": "IFLA_VFINFO_LIST",
            "array": [
                {
                    "vf": {
                        "type": "int"
                    },
                    "mac": {
                        "type": "string"
                    },
                    "vlan_list": {
                        "type": "array",
                        "attr": "IFLA_VF_VLAN_LIST",
                        "array": [
                            {
                                "vlan": {
                                    "type": "int"
                                },
                                "qos": {
                                    "type": "int"
                                },
                                "protocol": {
                                    "type": "string"
                                }
                            }
                        ]
                    },
                    "vlan": {
                        "type": "int",
                        "attr": "!IFLA_VF_VLAN_LIST && IFLA_VF_VLAN"
                    },
                    "qos": {
                        "type": "int",
                        "attr": "!IFLA_VF_VLAN_LIST && IFLA_VF_VLAN"
                    },
                    "tx_rate": {
                        "type": "int"
                    },
                    "rate": {
                        "type": "dict",
                        "attr": "IFLA_VF_RATE",
                        "dict": {
                            "max_tx": {
                                "type": "int"
                            },
                            "min_tx": {
                                "type": "int"
                            }
                        }
                    },
                    "spoofchk": {
                        "type": "bool",
                        "attr": "IFLA_VF_SPOOFCHK"
                    },
                    "link_state": {
                        "type": "string",
                        "attr": "IFLA_VF_LINK_STATE"
                    },
                    "trust": {
                        "type": "bool",
                        "attr": "IFLA_VF_TRUST"
                    },
                    "query_rss_en": {
                        "type": "bool",
                        "attr": "IFLA_VF_RSS_QUERY_EN"
                    },
                    "stats": {
                        "type": "dict",
                        "attr": "IFLA_VF_STATS",
                        "dict": {
                            "rx": {
                                "type": "dict",
                                "dict": {
                                    "bytes": {
                                        "type": "uint",
                                        "attr": "IFLA_VF_STATS_RX_BYTES"
                                    },
                                    "packets": {
                                        "type": "uint",
                                        "attr": "IFLA_VF_STATS_RX_PACKETS"
                                    },
                                    "multicast": {
                                        "type": "uint",
                                        "attr": "IFLA_VF_STATS_MULTICAST"
                                    },
                                    "broadcast": {
                                        "type": "uint",
                                        "attr": "IFLA_VF_STATS_BROADCAST"
                                    }
                                }
                            },
                            "tx": {
                                "type": "dict",
                                "dict": {
                                    "bytes": {
                                        "type": "uint",
                                        "attr": "IFLA_VF_STATS_TX_BYTES"
                                    },
                                    "packets": {
                                        "type": "uint",
                                        "attr": "IFLA_VF_STATS_TX_PACKETS"
                                    }
                                }
                            }
                        }
                    }
                }
            ]
        }
    }
]

Example with the config previously given:
Note that here, linkinfo attributes are not populated.
The schemas are provided in each link type patches.

$ ip -details -json link show
[{
        "ifindex": 1,
        "ifname": "lo",
        "flags": ["LOOPBACK","UP","LOWER_UP"],
        "mtu": 65536,
        "qdisc": "noqueue",
        "operstate": "UNKNOWN",
        "linkmode": "DEFAULT",
        "group": "default",
        "link_type": "loopback",
        "address": "00:00:00:00:00:00",
        "broadcast": "00:00:00:00:00:00",
        "promiscuity": 0,
        "inet6_addr_gen_mode": "eui64",
        "num_tx_queues": 1,
        "num_rx_queues": 1,
        "gso_max_size": 65536,
        "gso_max_segs": 65535
    },{
        "ifindex": 2,
        "ifname": "eth0",
        "flags": ["BROADCAST","MULTICAST","UP","LOWER_UP"],
        "mtu": 1500,
        "qdisc": "pfifo_fast",
        "operstate": "UP",
        "linkmode": "DEFAULT",
        "group": "default",
        "txqlen": 1000,
        "link_type": "ether",
        "address": "08:00:27:db:31:88",
        "broadcast": "ff:ff:ff:ff:ff:ff",
        "promiscuity": 0,
        "inet6_addr_gen_mode": "eui64",
        "num_tx_queues": 1,
        "num_rx_queues": 1,
        "gso_max_size": 65536,
        "gso_max_segs": 65535
    },{
        "ifindex": 3,
        "ifname": "swp1",
        "flags": ["BROADCAST","MULTICAST"],
        "mtu": 1500,
        "qdisc": "noop",
        "operstate": "DOWN",
        "linkmode": "DEFAULT",
        "group": "default",
        "txqlen": 1000,
        "link_type": "ether",
        "address": "08:00:27:5b:b1:75",
        "broadcast": "ff:ff:ff:ff:ff:ff",
        "promiscuity": 0,
        "inet6_addr_gen_mode": "eui64",
        "num_tx_queues": 1,
        "num_rx_queues": 1,
        "gso_max_size": 65536,
        "gso_max_segs": 65535
    },{
        "ifindex": 10,
        "ifname": "vxlan42",
        "flags": ["BROADCAST","MULTICAST"],
        "mtu": 1500,
        "qdisc": "noop",
        "master": "br0",
        "operstate": "DOWN",
        "linkmode": "DEFAULT",
        "group": "default",
        "link_type": "ether",
        "address": "4a:d9:91:42:a2:d2",
        "broadcast": "ff:ff:ff:ff:ff:ff",
        "promiscuity": 1,
        "linkinfo": {
            "info_kind": "vxlan",
            "info_data": {},
            "info_slave_kind": "bridge",
            "info_slave_data": {}
        },
        "inet6_addr_gen_mode": "eui64",
        "num_tx_queues": 1,
        "num_rx_queues": 1,
        "gso_max_size": 65536,
        "gso_max_segs": 65535
    },{
        "ifindex": 11,
        "ifname": "bond0",
        "flags": ["BROADCAST","MULTICAST","MASTER"],
        "mtu": 1500,
        "qdisc": "noop",
        "master": "br0",
        "operstate": "DOWN",
        "linkmode": "DEFAULT",
        "group": "default",
        "link_type": "ether",
        "address": "e2:aa:7b:17:c5:14",
        "broadcast": "ff:ff:ff:ff:ff:ff",
        "promiscuity": 1,
        "linkinfo": {
            "info_kind": "bond",
            "info_data": {},
            "info_slave_kind": "bridge",
            "info_slave_data": {},
        "inet6_addr_gen_mode": "eui64",
        "num_tx_queues": 16,
        "num_rx_queues": 16,
        "gso_max_size": 65536,
        "gso_max_segs": 65535
    },{
        "ifindex": 12,
        "ifname": "swp1.50",
        "link": "swp1",
        "flags": ["BROADCAST","MULTICAST","M-DOWN"],
        "mtu": 1500,
        "qdisc": "noop",
        "master": "br0",
        "operstate": "DOWN",
        "linkmode": "DEFAULT",
        "group": "default",
        "link_type": "ether",
        "address": "08:00:27:5b:b1:75",
        "broadcast": "ff:ff:ff:ff:ff:ff",
        "promiscuity": 1,
        "linkinfo": {
            "info_kind": "vlan",
            "info_data": {},
            "info_slave_kind": "bridge",
            "info_slave_data": {},
        "inet6_addr_gen_mode": "eui64",
        "num_tx_queues": 1,
        "num_rx_queues": 1,
        "gso_max_size": 65536,
        "gso_max_segs": 65535
    },{
        "ifindex": 13,
        "ifname": "br0",
        "flags": ["NO-CARRIER","BROADCAST","MULTICAST","UP"],
        "mtu": 1500,
        "qdisc": "noqueue",
        "operstate": "DOWN",
        "linkmode": "DEFAULT",
        "group": "default",
        "link_type": "ether",
        "address": "08:00:27:5b:b1:75",
        "broadcast": "ff:ff:ff:ff:ff:ff",
        "promiscuity": 0,
        "linkinfo": {
            "info_kind": "bridge",
            "info_data": {},
        "inet6_addr_gen_mode": "eui64",
        "num_tx_queues": 1,
        "num_rx_queues": 1,
        "gso_max_size": 65536,
        "gso_max_segs": 65535
    }
]

Signed-off-by: Julien Fortin <julien@cumulusnetworks.com>
---
 ip/ipaddress.c | 1089 +++++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 766 insertions(+), 323 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index cf8ef818..293d958c 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -30,6 +30,7 @@
 #include <linux/sockios.h>
 #include <linux/net_namespace.h>
 
+#include "utils.h"
 #include "rt_names.h"
 #include "utils.h"
 #include "ll_map.h"
@@ -84,13 +85,14 @@ static void usage(void)
 
 static void print_link_flags(FILE *fp, unsigned int flags, unsigned int mdown)
 {
-	fprintf(fp, "<");
+	open_json_array(PRINT_ANY, is_json_context() ? "flags" : "<");
 	if (flags & IFF_UP && !(flags & IFF_RUNNING))
-		fprintf(fp, "NO-CARRIER%s", flags ? "," : "");
+		print_string(PRINT_ANY, NULL,
+			     flags ? "%s," : "%s", "NO-CARRIER");
 	flags &= ~IFF_RUNNING;
-#define _PF(f) if (flags&IFF_##f) { \
-		  flags &= ~IFF_##f ; \
-		  fprintf(fp, #f "%s", flags ? "," : ""); }
+#define _PF(f) if (flags&IFF_##f) {					\
+		flags &= ~IFF_##f ;					\
+		print_string(PRINT_ANY, NULL, flags ? "%s," : "%s", #f); }
 	_PF(LOOPBACK);
 	_PF(BROADCAST);
 	_PF(POINTOPOINT);
@@ -111,10 +113,10 @@ static void print_link_flags(FILE *fp, unsigned int flags, unsigned int mdown)
 	_PF(ECHO);
 #undef _PF
 	if (flags)
-		fprintf(fp, "%x", flags);
+		print_hex(PRINT_ANY, NULL, "%x", flags);
 	if (mdown)
-		fprintf(fp, ",M-DOWN");
-	fprintf(fp, "> ");
+		print_string(PRINT_ANY, NULL, ",%s", "M-DOWN");
+	close_json_array(PRINT_ANY, "> ");
 }
 
 static const char *oper_states[] = {
@@ -125,14 +127,26 @@ static const char *oper_states[] = {
 static void print_operstate(FILE *f, __u8 state)
 {
 	if (state >= ARRAY_SIZE(oper_states)) {
-		fprintf(f, "state %#x ", state);
+		if (is_json_context())
+			print_uint(PRINT_JSON, "operstate_index", NULL, state);
+		else
+			print_0xhex(PRINT_FP, NULL, "state %#x", state);
 	} else if (brief) {
-		color_fprintf(f, oper_state_color(state),
-			      "%-14s ", oper_states[state]);
+		print_color_string(PRINT_ANY,
+				   oper_state_color(state),
+				   "operstate",
+				   "%-14s ",
+				   oper_states[state]);
 	} else {
-		fprintf(f, "state ");
-		color_fprintf(f, oper_state_color(state),
-			      "%s ", oper_states[state]);
+		if (is_json_context())
+			print_string(PRINT_JSON,
+				     "operstate",
+				     NULL, oper_states[state]);
+		else {
+			fprintf(f, "state ");
+			color_fprintf(f, oper_state_color(state),
+				      "%s ", oper_states[state]);
+		}
 	}
 }
 
@@ -169,7 +183,7 @@ static void print_queuelen(FILE *f, struct rtattr *tb[IFLA_MAX + 1])
 		qlen = ifr.ifr_qlen;
 	}
 	if (qlen)
-		fprintf(f, "qlen %d", qlen);
+		print_int(PRINT_ANY, "txqlen", "qlen %d", qlen);
 }
 
 static const char *link_modes[] = {
@@ -181,9 +195,15 @@ static void print_linkmode(FILE *f, struct rtattr *tb)
 	unsigned int mode = rta_getattr_u8(tb);
 
 	if (mode >= ARRAY_SIZE(link_modes))
-		fprintf(f, "mode %d ", mode);
+		print_int(PRINT_ANY,
+			  "linkmode_index",
+			  "mode %d ",
+			  mode);
 	else
-		fprintf(f, "mode %s ", link_modes[mode]);
+		print_string(PRINT_ANY,
+			     "linkmode",
+			     "mode %s "
+			     , link_modes[mode]);
 }
 
 static char *parse_link_kind(struct rtattr *tb, bool slave)
@@ -215,13 +235,14 @@ static void print_linktype(FILE *fp, struct rtattr *tb)
 	char slave[32];
 
 	parse_rtattr_nested(linkinfo, IFLA_INFO_MAX, tb);
+	open_json_object("linkinfo");
 
 	if (linkinfo[IFLA_INFO_KIND]) {
 		const char *kind
 			= rta_getattr_str(linkinfo[IFLA_INFO_KIND]);
 
-		fprintf(fp, "%s", _SL_);
-		fprintf(fp, "    %s ", kind);
+		print_string(PRINT_FP, NULL, "%s", _SL_);
+		print_string(PRINT_ANY, "info_kind", "    %s ", kind);
 
 		lu = get_link_kind(kind);
 		if (lu && lu->print_opt) {
@@ -232,11 +253,16 @@ static void print_linktype(FILE *fp, struct rtattr *tb)
 						    linkinfo[IFLA_INFO_DATA]);
 				data = attr;
 			}
+			open_json_object("info_data");
 			lu->print_opt(lu, fp, data);
+			close_json_object();
 
 			if (linkinfo[IFLA_INFO_XSTATS] && show_stats &&
-			    lu->print_xstats)
+			    lu->print_xstats) {
+				open_json_object("info_xstats");
 				lu->print_xstats(lu, fp, linkinfo[IFLA_INFO_XSTATS]);
+				close_json_object();
+			}
 		}
 	}
 
@@ -244,8 +270,12 @@ static void print_linktype(FILE *fp, struct rtattr *tb)
 		const char *slave_kind
 			= rta_getattr_str(linkinfo[IFLA_INFO_SLAVE_KIND]);
 
-		fprintf(fp, "%s", _SL_);
-		fprintf(fp, "    %s_slave ", slave_kind);
+		print_string(PRINT_FP, NULL, "%s", _SL_);
+		print_string(PRINT_ANY,
+			     "info_slave_kind",
+			     "    %s_slave ",
+			     slave_kind);
+
 		snprintf(slave, sizeof(slave), "%s_slave", slave_kind);
 
 		slave_lu = get_link_kind(slave);
@@ -257,9 +287,12 @@ static void print_linktype(FILE *fp, struct rtattr *tb)
 						    linkinfo[IFLA_INFO_SLAVE_DATA]);
 				data = attr;
 			}
+			open_json_object("info_slave_data");
 			slave_lu->print_opt(slave_lu, fp, data);
+			close_json_object();
 		}
 	}
+	close_json_object();
 }
 
 static void print_af_spec(FILE *fp, struct rtattr *af_spec_attr)
@@ -275,22 +308,39 @@ static void print_af_spec(FILE *fp, struct rtattr *af_spec_attr)
 
 	if (tb[IFLA_INET6_ADDR_GEN_MODE]) {
 		__u8 mode = rta_getattr_u8(tb[IFLA_INET6_ADDR_GEN_MODE]);
+		SPRINT_BUF(b1);
 
 		switch (mode) {
 		case IN6_ADDR_GEN_MODE_EUI64:
-			fprintf(fp, "addrgenmode eui64 ");
+			print_string(PRINT_ANY,
+				     "inet6_addr_gen_mode",
+				     "addrgenmode %s ",
+				     "eui64");
 			break;
 		case IN6_ADDR_GEN_MODE_NONE:
-			fprintf(fp, "addrgenmode none ");
+			print_string(PRINT_ANY,
+				     "inet6_addr_gen_mode",
+				     "addrgenmode %s ",
+				     "none");
 			break;
 		case IN6_ADDR_GEN_MODE_STABLE_PRIVACY:
-			fprintf(fp, "addrgenmode stable_secret ");
+			print_string(PRINT_ANY,
+				     "inet6_addr_gen_mode",
+				     "addrgenmode %s ",
+				     "stable_secret");
 			break;
 		case IN6_ADDR_GEN_MODE_RANDOM:
-			fprintf(fp, "addrgenmode random ");
+			print_string(PRINT_ANY,
+				     "inet6_addr_gen_mode",
+				     "addrgenmode %s ",
+				     "random");
 			break;
 		default:
-			fprintf(fp, "addrgenmode %#.2hhx ", mode);
+			snprintf(b1, sizeof(b1), "%#.2hhx", mode);
+			print_string(PRINT_ANY,
+				     "inet6_addr_gen_mode",
+				     "addrgenmode %s ",
+				     b1);
 			break;
 		}
 	}
@@ -316,83 +366,135 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
 	vf_mac = RTA_DATA(vf[IFLA_VF_MAC]);
 	vf_tx_rate = RTA_DATA(vf[IFLA_VF_TX_RATE]);
 
-	fprintf(fp, "%s    vf %d MAC %s", _SL_, vf_mac->vf,
-		ll_addr_n2a((unsigned char *)&vf_mac->mac,
-			    ETH_ALEN, 0, b1, sizeof(b1)));
+	print_string(PRINT_FP, NULL, "%s    ", _SL_);
+	print_int(PRINT_ANY, "vf", "vf %d ", vf_mac->vf);
+	print_string(PRINT_ANY, "mac", "MAC %s",
+		     ll_addr_n2a((unsigned char *) &vf_mac->mac,
+				 ETH_ALEN, 0, b1, sizeof(b1)));
+
 	if (vf[IFLA_VF_VLAN_LIST]) {
 		struct rtattr *i, *vfvlanlist = vf[IFLA_VF_VLAN_LIST];
 		int rem = RTA_PAYLOAD(vfvlanlist);
 
+		open_json_array(PRINT_JSON, "vlan_list");
 		for (i = RTA_DATA(vfvlanlist);
-		      RTA_OK(i, rem); i = RTA_NEXT(i, rem)) {
-			struct ifla_vf_vlan_info *vf_vlan_info =
-					RTA_DATA(i);
+		     RTA_OK(i, rem); i = RTA_NEXT(i, rem)) {
+			struct ifla_vf_vlan_info *vf_vlan_info = RTA_DATA(i);
 			SPRINT_BUF(b2);
 
+			open_json_object(NULL);
 			if (vf_vlan_info->vlan)
-				fprintf(fp, ", vlan %d", vf_vlan_info->vlan);
+				print_int(PRINT_ANY,
+					  "vlan",
+					  ", vlan %d",
+					  vf_vlan_info->vlan);
 			if (vf_vlan_info->qos)
-				fprintf(fp, ", qos %d", vf_vlan_info->qos);
+				print_int(PRINT_ANY,
+					  "qos",
+					  ", qos %d",
+					  vf_vlan_info->qos);
 			if (vf_vlan_info->vlan_proto &&
 			    vf_vlan_info->vlan_proto != htons(ETH_P_8021Q))
-				fprintf(fp, ", vlan protocol %s",
-					ll_proto_n2a(vf_vlan_info->vlan_proto,
+				print_string(PRINT_ANY,
+					     "protocol",
+					     ", vlan protocol %s",
+					     ll_proto_n2a(
+						     vf_vlan_info->vlan_proto,
 						     b2, sizeof(b2)));
-
+			close_json_object();
 		}
+		close_json_array(PRINT_JSON, NULL);
 	} else {
 		struct ifla_vf_vlan *vf_vlan = RTA_DATA(vf[IFLA_VF_VLAN]);
 
 		if (vf_vlan->vlan)
-			fprintf(fp, ", vlan %d", vf_vlan->vlan);
+			print_int(PRINT_ANY,
+				  "vlan",
+				  ", vlan %d",
+				  vf_vlan->vlan);
 		if (vf_vlan->qos)
-			fprintf(fp, ", qos %d", vf_vlan->qos);
+			print_int(PRINT_ANY, "qos", ", qos %d", vf_vlan->qos);
 	}
+
 	if (vf_tx_rate->rate)
-		fprintf(fp, ", tx rate %d (Mbps)", vf_tx_rate->rate);
+		print_int(PRINT_ANY,
+			  "tx_rate",
+			  ", tx rate %d (Mbps)",
+			  vf_tx_rate->rate);
 
 	if (vf[IFLA_VF_RATE]) {
 		struct ifla_vf_rate *vf_rate = RTA_DATA(vf[IFLA_VF_RATE]);
-
-		if (vf_rate->max_tx_rate)
-			fprintf(fp, ", max_tx_rate %dMbps", vf_rate->max_tx_rate);
-		if (vf_rate->min_tx_rate)
-			fprintf(fp, ", min_tx_rate %dMbps", vf_rate->min_tx_rate);
+		int max_tx = vf_rate->max_tx_rate;
+		int min_tx = vf_rate->min_tx_rate;
+
+		if (is_json_context()) {
+			open_json_object("rate");
+			print_int(PRINT_JSON, "max_tx", NULL, max_tx);
+			print_int(PRINT_ANY, "min_tx", NULL, min_tx);
+			close_json_object();
+		} else {
+			if (max_tx)
+				fprintf(fp, ", max_tx_rate %dMbps", max_tx);
+			if (min_tx)
+				fprintf(fp, ", min_tx_rate %dMbps", min_tx);
+		}
 	}
+
 	if (vf[IFLA_VF_SPOOFCHK]) {
 		struct ifla_vf_spoofchk *vf_spoofchk =
 			RTA_DATA(vf[IFLA_VF_SPOOFCHK]);
 
 		if (vf_spoofchk->setting != -1)
-			fprintf(fp, ", spoof checking %s",
-				vf_spoofchk->setting ? "on" : "off");
+			print_bool(PRINT_ANY,
+				   "spoofchk",
+				   vf_spoofchk->setting ?
+				   ", spoof checking on" : ", spoof checking off",
+				   vf_spoofchk->setting);
 	}
+
 	if (vf[IFLA_VF_LINK_STATE]) {
 		struct ifla_vf_link_state *vf_linkstate =
 			RTA_DATA(vf[IFLA_VF_LINK_STATE]);
 
 		if (vf_linkstate->link_state == IFLA_VF_LINK_STATE_AUTO)
-			fprintf(fp, ", link-state auto");
+			print_string(PRINT_ANY,
+				     "link_state",
+				     ", link-state %s",
+				     "auto");
 		else if (vf_linkstate->link_state == IFLA_VF_LINK_STATE_ENABLE)
-			fprintf(fp, ", link-state enable");
+			print_string(PRINT_ANY,
+				     "link_state",
+				     ", link-state %s",
+				     "enable");
 		else
-			fprintf(fp, ", link-state disable");
+			print_string(PRINT_ANY,
+				     "link_state",
+				     ", link-state %s",
+				     "disable");
 	}
+
 	if (vf[IFLA_VF_TRUST]) {
 		struct ifla_vf_trust *vf_trust = RTA_DATA(vf[IFLA_VF_TRUST]);
 
 		if (vf_trust->setting != -1)
-			fprintf(fp, ", trust %s",
-				vf_trust->setting ? "on" : "off");
+			print_bool(PRINT_ANY,
+				   "trust",
+				   vf_trust->setting ? ", trust on" : ", trust off",
+				   vf_trust->setting);
 	}
+
 	if (vf[IFLA_VF_RSS_QUERY_EN]) {
 		struct ifla_vf_rss_query_en *rss_query =
 			RTA_DATA(vf[IFLA_VF_RSS_QUERY_EN]);
 
 		if (rss_query->setting != -1)
-			fprintf(fp, ", query_rss %s",
-			        rss_query->setting ? "on" : "off");
+			print_bool(PRINT_ANY,
+				   "query_rss_en",
+				   rss_query->setting ? ", query_rss on"
+				   : ", query_rss off",
+				   rss_query->setting);
 	}
+
 	if (vf[IFLA_VF_STATS] && show_stats)
 		print_vf_stats64(fp, vf[IFLA_VF_STATS]);
 }
@@ -432,7 +534,7 @@ void print_num(FILE *fp, unsigned int width, uint64_t count)
 	}
 
 	snprintf(buf, sizeof(buf), "%.*f%c%s", precision,
-		(double) count / powi, *prefix, use_iec ? "i" : "");
+		 (double) count / powi, *prefix, use_iec ? "i" : "");
 
 	fprintf(fp, "%-*s ", width, buf);
 }
@@ -448,155 +550,337 @@ static void print_vf_stats64(FILE *fp, struct rtattr *vfstats)
 
 	parse_rtattr_nested(vf, IFLA_VF_MAX, vfstats);
 
-	/* RX stats */
-	fprintf(fp, "%s", _SL_);
-	fprintf(fp, "    RX: bytes  packets  mcast   bcast %s", _SL_);
-	fprintf(fp, "    ");
+	if (is_json_context()) {
+		open_json_object("stats");
+
+		/* RX stats */
+		open_json_object("rx");
+		print_uint(PRINT_JSON, "bytes", NULL,
+			   rta_getattr_u64(vf[IFLA_VF_STATS_RX_BYTES]));
+		print_uint(PRINT_JSON, "packets", NULL,
+			   rta_getattr_u64(vf[IFLA_VF_STATS_RX_PACKETS]));
+		print_uint(PRINT_JSON, "multicast", NULL,
+			   rta_getattr_u64(vf[IFLA_VF_STATS_MULTICAST]));
+		print_uint(PRINT_JSON, "broadcast", NULL,
+			   rta_getattr_u64(vf[IFLA_VF_STATS_BROADCAST]));
+		close_json_object();
+
+		/* TX stats */
+		open_json_object("tx");
+		print_uint(PRINT_JSON, "tx_bytes", NULL,
+			   rta_getattr_u64(vf[IFLA_VF_STATS_TX_BYTES]));
+		print_uint(PRINT_JSON, "tx_packets", NULL,
+			   rta_getattr_u64(vf[IFLA_VF_STATS_TX_PACKETS]));
+		close_json_object();
+		close_json_object();
+	} else {
+		/* RX stats */
+		fprintf(fp, "%s", _SL_);
+		fprintf(fp, "    RX: bytes  packets  mcast   bcast %s", _SL_);
+		fprintf(fp, "    ");
 
-	print_num(fp, 10,  rta_getattr_u64(vf[IFLA_VF_STATS_RX_BYTES]));
-	print_num(fp, 8, rta_getattr_u64(vf[IFLA_VF_STATS_RX_PACKETS]));
-	print_num(fp, 7, rta_getattr_u64(vf[IFLA_VF_STATS_MULTICAST]));
-	print_num(fp, 7, rta_getattr_u64(vf[IFLA_VF_STATS_BROADCAST]));
+		print_num(fp, 10, rta_getattr_u64(vf[IFLA_VF_STATS_RX_BYTES]));
+		print_num(fp, 8, rta_getattr_u64(vf[IFLA_VF_STATS_RX_PACKETS]));
+		print_num(fp, 7, rta_getattr_u64(vf[IFLA_VF_STATS_MULTICAST]));
+		print_num(fp, 7, rta_getattr_u64(vf[IFLA_VF_STATS_BROADCAST]));
 
-	/* TX stats */
-	fprintf(fp, "%s", _SL_);
-	fprintf(fp, "    TX: bytes  packets %s", _SL_);
-	fprintf(fp, "    ");
+		/* TX stats */
+		fprintf(fp, "%s", _SL_);
+		fprintf(fp, "    TX: bytes  packets %s", _SL_);
+		fprintf(fp, "    ");
 
-	print_num(fp, 10, rta_getattr_u64(vf[IFLA_VF_STATS_TX_BYTES]));
-	print_num(fp, 8, rta_getattr_u64(vf[IFLA_VF_STATS_TX_PACKETS]));
+		print_num(fp, 10, rta_getattr_u64(vf[IFLA_VF_STATS_TX_BYTES]));
+		print_num(fp, 8, rta_getattr_u64(vf[IFLA_VF_STATS_TX_PACKETS]));
+	}
 }
 
 static void print_link_stats64(FILE *fp, const struct rtnl_link_stats64 *s,
 			       const struct rtattr *carrier_changes)
 {
-	/* RX stats */
-	fprintf(fp, "    RX: bytes  packets  errors  dropped overrun mcast   %s%s",
-		s->rx_compressed ? "compressed" : "", _SL_);
-
-	fprintf(fp, "    ");
-	print_num(fp, 10, s->rx_bytes);
-	print_num(fp, 8, s->rx_packets);
-	print_num(fp, 7, s->rx_errors);
-	print_num(fp, 7, s->rx_dropped);
-	print_num(fp, 7, s->rx_over_errors);
-	print_num(fp, 7, s->multicast);
-	if (s->rx_compressed)
-		print_num(fp, 7, s->rx_compressed);
-
-	/* RX error stats */
-	if (show_stats > 1) {
-		fprintf(fp, "%s", _SL_);
-		fprintf(fp, "    RX errors: length   crc     frame   fifo    missed%s%s",
-			s->rx_nohandler ? "   nohandler" : "",  _SL_);
-
-		fprintf(fp, "               ");
-		print_num(fp, 8, s->rx_length_errors);
-		print_num(fp, 7, s->rx_crc_errors);
-		print_num(fp, 7, s->rx_frame_errors);
-		print_num(fp, 7, s->rx_fifo_errors);
-		print_num(fp, 7, s->rx_missed_errors);
-		if (s->rx_nohandler)
-			print_num(fp, 7, s->rx_nohandler);
+	if (is_json_context()) {
+		open_json_object("stats644");
+
+		/* RX stats */
+		open_json_object("rx");
+		print_uint(PRINT_JSON, "bytes", NULL, s->rx_bytes);
+		print_uint(PRINT_JSON, "packets", NULL, s->rx_packets);
+		print_uint(PRINT_JSON, "errors", NULL, s->rx_errors);
+		print_uint(PRINT_JSON, "dropped", NULL, s->rx_dropped);
+		print_uint(PRINT_JSON, "over_errors", NULL, s->rx_over_errors);
+		print_uint(PRINT_JSON, "multicast", NULL, s->multicast);
+		if (s->rx_compressed)
+			print_uint(PRINT_JSON,
+				   "compressed",
+				   NULL, s->rx_compressed);
+
+		/* RX error stats */
+		if (show_stats > 1) {
+			print_uint(PRINT_JSON,
+				   "length_errors",
+				   NULL, s->rx_length_errors);
+			print_uint(PRINT_JSON,
+				   "crc_errors",
+				   NULL, s->rx_crc_errors);
+			print_uint(PRINT_JSON,
+				   "frame_errors",
+				   NULL, s->rx_frame_errors);
+			print_uint(PRINT_JSON,
+				   "fifo_errors",
+				   NULL, s->rx_fifo_errors);
+			print_uint(PRINT_JSON,
+				   "missed_errors",
+				   NULL, s->rx_missed_errors);
+			if (s->rx_nohandler)
+				print_uint(PRINT_JSON,
+					   "nohandler", NULL, s->rx_nohandler);
+		}
+		close_json_object();
+
+		/* TX stats */
+		open_json_object("tx");
+		print_uint(PRINT_JSON, "bytes", NULL, s->tx_bytes);
+		print_uint(PRINT_JSON, "packets", NULL, s->tx_packets);
+		print_uint(PRINT_JSON, "errors", NULL, s->tx_errors);
+		print_uint(PRINT_JSON, "dropped", NULL, s->tx_dropped);
+		print_uint(PRINT_JSON,
+			   "carrier_errors",
+			   NULL, s->tx_carrier_errors);
+		print_uint(PRINT_JSON, "collisions", NULL, s->collisions);
+		if (s->tx_compressed)
+			print_uint(PRINT_JSON,
+				   "compressed",
+				   NULL, s->tx_compressed);
+
+		/* TX error stats */
+		if (show_stats > 1) {
+			print_uint(PRINT_JSON,
+				   "aborted_errors",
+				   NULL, s->tx_aborted_errors);
+			print_uint(PRINT_JSON,
+				   "fifo_errors",
+				   NULL, s->tx_fifo_errors);
+			print_uint(PRINT_JSON,
+				   "window_errors",
+				   NULL, s->tx_window_errors);
+			print_uint(PRINT_JSON,
+				   "heartbeat_errors",
+				   NULL, s->tx_heartbeat_errors);
+			if (carrier_changes)
+				print_uint(PRINT_JSON, "carrier_changes", NULL,
+					   rta_getattr_u32(carrier_changes));
+		}
+		close_json_object();
+		close_json_object();
 
-	}
-	fprintf(fp, "%s", _SL_);
+	} else {
+		/* RX stats */
+		fprintf(fp, "    RX: bytes  packets  errors  dropped overrun mcast   %s%s",
+			s->rx_compressed ? "compressed" : "", _SL_);
+
+		fprintf(fp, "    ");
+		print_num(fp, 10, s->rx_bytes);
+		print_num(fp, 8, s->rx_packets);
+		print_num(fp, 7, s->rx_errors);
+		print_num(fp, 7, s->rx_dropped);
+		print_num(fp, 7, s->rx_over_errors);
+		print_num(fp, 7, s->multicast);
+		if (s->rx_compressed)
+			print_num(fp, 7, s->rx_compressed);
+
+		/* RX error stats */
+		if (show_stats > 1) {
+			fprintf(fp, "%s", _SL_);
+			fprintf(fp, "    RX errors: length   crc     frame   fifo    missed%s%s",
+				s->rx_nohandler ? "   nohandler" : "", _SL_);
+
+			fprintf(fp, "               ");
+			print_num(fp, 8, s->rx_length_errors);
+			print_num(fp, 7, s->rx_crc_errors);
+			print_num(fp, 7, s->rx_frame_errors);
+			print_num(fp, 7, s->rx_fifo_errors);
+			print_num(fp, 7, s->rx_missed_errors);
+			if (s->rx_nohandler)
+				print_num(fp, 7, s->rx_nohandler);
 
-	/* TX stats */
-	fprintf(fp, "    TX: bytes  packets  errors  dropped carrier collsns %s%s",
-		s->tx_compressed ? "compressed" : "", _SL_);
-
-	fprintf(fp, "    ");
-	print_num(fp, 10, s->tx_bytes);
-	print_num(fp, 8, s->tx_packets);
-	print_num(fp, 7, s->tx_errors);
-	print_num(fp, 7, s->tx_dropped);
-	print_num(fp, 7, s->tx_carrier_errors);
-	print_num(fp, 7, s->collisions);
-	if (s->tx_compressed)
-		print_num(fp, 7, s->tx_compressed);
-
-	/* TX error stats */
-	if (show_stats > 1) {
-		fprintf(fp, "%s", _SL_);
-		fprintf(fp, "    TX errors: aborted  fifo   window heartbeat");
-		if (carrier_changes)
-			fprintf(fp, " transns");
+		}
 		fprintf(fp, "%s", _SL_);
 
-		fprintf(fp, "               ");
-		print_num(fp, 8, s->tx_aborted_errors);
-		print_num(fp, 7, s->tx_fifo_errors);
-		print_num(fp, 7, s->tx_window_errors);
-		print_num(fp, 7, s->tx_heartbeat_errors);
-		if (carrier_changes)
-			print_num(fp, 7, rta_getattr_u32(carrier_changes));
+		/* TX stats */
+		fprintf(fp, "    TX: bytes  packets  errors  dropped carrier collsns %s%s",
+			s->tx_compressed ? "compressed" : "", _SL_);
+
+		fprintf(fp, "    ");
+		print_num(fp, 10, s->tx_bytes);
+		print_num(fp, 8, s->tx_packets);
+		print_num(fp, 7, s->tx_errors);
+		print_num(fp, 7, s->tx_dropped);
+		print_num(fp, 7, s->tx_carrier_errors);
+		print_num(fp, 7, s->collisions);
+		if (s->tx_compressed)
+			print_num(fp, 7, s->tx_compressed);
+
+		/* TX error stats */
+		if (show_stats > 1) {
+			fprintf(fp, "%s", _SL_);
+			fprintf(fp, "    TX errors: aborted  fifo   window heartbeat");
+			if (carrier_changes)
+				fprintf(fp, " transns");
+			fprintf(fp, "%s", _SL_);
+
+			fprintf(fp, "               ");
+			print_num(fp, 8, s->tx_aborted_errors);
+			print_num(fp, 7, s->tx_fifo_errors);
+			print_num(fp, 7, s->tx_window_errors);
+			print_num(fp, 7, s->tx_heartbeat_errors);
+			if (carrier_changes)
+				print_num(fp, 7, rta_getattr_u32(carrier_changes));
+		}
 	}
 }
 
 static void print_link_stats32(FILE *fp, const struct rtnl_link_stats *s,
 			       const struct rtattr *carrier_changes)
 {
-	/* RX stats */
-	fprintf(fp, "    RX: bytes  packets  errors  dropped overrun mcast   %s%s",
-		s->rx_compressed ? "compressed" : "", _SL_);
-
-
-	fprintf(fp, "    ");
-	print_num(fp, 10, s->rx_bytes);
-	print_num(fp, 8, s->rx_packets);
-	print_num(fp, 7, s->rx_errors);
-	print_num(fp, 7, s->rx_dropped);
-	print_num(fp, 7, s->rx_over_errors);
-	print_num(fp, 7, s->multicast);
-	if (s->rx_compressed)
-		print_num(fp, 7, s->rx_compressed);
-
-	/* RX error stats */
-	if (show_stats > 1) {
-		fprintf(fp, "%s", _SL_);
-		fprintf(fp, "    RX errors: length   crc     frame   fifo    missed%s%s",
-			s->rx_nohandler ? "   nohandler" : "",  _SL_);
-		fprintf(fp, "               ");
-		print_num(fp, 8, s->rx_length_errors);
-		print_num(fp, 7, s->rx_crc_errors);
-		print_num(fp, 7, s->rx_frame_errors);
-		print_num(fp, 7, s->rx_fifo_errors);
-		print_num(fp, 7, s->rx_missed_errors);
-		if (s->rx_nohandler)
-			print_num(fp, 7, s->rx_nohandler);
-	}
-	fprintf(fp, "%s", _SL_);
+	if (is_json_context()) {
+		open_json_object("stats");
+
+		/* RX stats */
+		open_json_object("rx");
+		print_uint(PRINT_JSON, "bytes", NULL, s->rx_bytes);
+		print_uint(PRINT_JSON, "packets", NULL, s->rx_packets);
+		print_uint(PRINT_JSON, "errors", NULL, s->rx_errors);
+		print_uint(PRINT_JSON, "dropped", NULL, s->rx_dropped);
+		print_uint(PRINT_JSON, "over_errors", NULL, s->rx_over_errors);
+		print_uint(PRINT_JSON, "multicast", NULL, s->multicast);
+		if (s->rx_compressed)
+			print_int(PRINT_JSON,
+				  "compressed",
+				  NULL, s->rx_compressed);
+
+		/* RX error stats */
+		if (show_stats > 1) {
+			print_uint(PRINT_JSON,
+				   "length_errors",
+				   NULL, s->rx_length_errors);
+			print_uint(PRINT_JSON,
+				   "crc_errors",
+				   NULL, s->rx_crc_errors);
+			print_uint(PRINT_JSON,
+				   "frame_errors",
+				   NULL, s->rx_frame_errors);
+			print_uint(PRINT_JSON,
+				   "fifo_errors",
+				   NULL, s->rx_fifo_errors);
+			print_uint(PRINT_JSON,
+				   "missed_errors",
+				   NULL, s->rx_missed_errors);
+			if (s->rx_nohandler)
+				print_int(PRINT_JSON,
+					  "nohandler",
+					  NULL, s->rx_nohandler);
+		}
+		close_json_object();
+
+		/* TX stats */
+		open_json_object("tx");
+		print_uint(PRINT_JSON, "bytes", NULL, s->tx_bytes);
+		print_uint(PRINT_JSON, "packets", NULL, s->tx_packets);
+		print_uint(PRINT_JSON, "errors", NULL, s->tx_errors);
+		print_uint(PRINT_JSON, "dropped", NULL, s->tx_dropped);
+		print_uint(PRINT_JSON,
+			   "carrier_errors",
+			   NULL, s->tx_carrier_errors);
+		print_uint(PRINT_JSON, "collisions", NULL, s->collisions);
+		if (s->tx_compressed)
+			print_int(PRINT_JSON,
+				  "compressed",
+				  NULL, s->tx_compressed);
+
+		/* TX error stats */
+		if (show_stats > 1) {
+			print_uint(PRINT_JSON,
+				   "aborted_errors",
+				   NULL, s->tx_aborted_errors);
+			print_uint(PRINT_JSON,
+				   "fifo_errors",
+				   NULL, s->tx_fifo_errors);
+			print_uint(PRINT_JSON,
+				   "window_errors",
+				   NULL, s->tx_window_errors);
+			print_uint(PRINT_JSON,
+				   "heartbeat_errors",
+				   NULL, s->tx_heartbeat_errors);
+			if (carrier_changes)
+				print_uint(PRINT_JSON,
+					   "carrier_changes",
+					   NULL,
+					   rta_getattr_u32(carrier_changes));
+		}
 
-	/* TX stats */
-	fprintf(fp, "    TX: bytes  packets  errors  dropped carrier collsns %s%s",
-		s->tx_compressed ? "compressed" : "", _SL_);
-
-	fprintf(fp, "    ");
-	print_num(fp, 10, s->tx_bytes);
-	print_num(fp, 8, s->tx_packets);
-	print_num(fp, 7, s->tx_errors);
-	print_num(fp, 7, s->tx_dropped);
-	print_num(fp, 7, s->tx_carrier_errors);
-	print_num(fp, 7, s->collisions);
-	if (s->tx_compressed)
-		print_num(fp, 7, s->tx_compressed);
-
-	/* TX error stats */
-	if (show_stats > 1) {
-		fprintf(fp, "%s", _SL_);
-		fprintf(fp, "    TX errors: aborted  fifo   window heartbeat");
-		if (carrier_changes)
-			fprintf(fp, " transns");
+		close_json_object();
+		close_json_object();
+	} else {
+		/* RX stats */
+		fprintf(fp, "    RX: bytes  packets  errors  dropped overrun mcast   %s%s",
+			s->rx_compressed ? "compressed" : "", _SL_);
+
+
+		fprintf(fp, "    ");
+		print_num(fp, 10, s->rx_bytes);
+		print_num(fp, 8, s->rx_packets);
+		print_num(fp, 7, s->rx_errors);
+		print_num(fp, 7, s->rx_dropped);
+		print_num(fp, 7, s->rx_over_errors);
+		print_num(fp, 7, s->multicast);
+		if (s->rx_compressed)
+			print_num(fp, 7, s->rx_compressed);
+
+		/* RX error stats */
+		if (show_stats > 1) {
+			fprintf(fp, "%s", _SL_);
+			fprintf(fp, "    RX errors: length   crc     frame   fifo    missed%s%s",
+				s->rx_nohandler ? "   nohandler" : "", _SL_);
+			fprintf(fp, "               ");
+			print_num(fp, 8, s->rx_length_errors);
+			print_num(fp, 7, s->rx_crc_errors);
+			print_num(fp, 7, s->rx_frame_errors);
+			print_num(fp, 7, s->rx_fifo_errors);
+			print_num(fp, 7, s->rx_missed_errors);
+			if (s->rx_nohandler)
+				print_num(fp, 7, s->rx_nohandler);
+		}
 		fprintf(fp, "%s", _SL_);
 
-		fprintf(fp, "               ");
-		print_num(fp, 8, s->tx_aborted_errors);
-		print_num(fp, 7, s->tx_fifo_errors);
-		print_num(fp, 7, s->tx_window_errors);
-		print_num(fp, 7, s->tx_heartbeat_errors);
-		if (carrier_changes)
-			print_num(fp, 7, rta_getattr_u32(carrier_changes));
+		/* TX stats */
+		fprintf(fp, "    TX: bytes  packets  errors  dropped carrier collsns %s%s",
+			s->tx_compressed ? "compressed" : "", _SL_);
+
+		fprintf(fp, "    ");
+		print_num(fp, 10, s->tx_bytes);
+		print_num(fp, 8, s->tx_packets);
+		print_num(fp, 7, s->tx_errors);
+		print_num(fp, 7, s->tx_dropped);
+		print_num(fp, 7, s->tx_carrier_errors);
+		print_num(fp, 7, s->collisions);
+		if (s->tx_compressed)
+			print_num(fp, 7, s->tx_compressed);
+
+		/* TX error stats */
+		if (show_stats > 1) {
+			fprintf(fp, "%s", _SL_);
+			fprintf(fp, "    TX errors: aborted  fifo   window heartbeat");
+			if (carrier_changes)
+				fprintf(fp, " transns");
+			fprintf(fp, "%s", _SL_);
+
+			fprintf(fp, "               ");
+			print_num(fp, 8, s->tx_aborted_errors);
+			print_num(fp, 7, s->tx_fifo_errors);
+			print_num(fp, 7, s->tx_window_errors);
+			print_num(fp, 7, s->tx_heartbeat_errors);
+			if (carrier_changes)
+				print_num(fp, 7, rta_getattr_u32(carrier_changes));
+		}
 	}
 }
 
@@ -694,44 +978,50 @@ int print_linkinfo_brief(const struct sockaddr_nl *who,
 		return -1;
 
 	if (n->nlmsg_type == RTM_DELLINK)
-		fprintf(fp, "Deleted ");
+		print_bool(PRINT_ANY, "deleted", "Deleted ", true);
 
 	if (tb[IFLA_LINK]) {
 		SPRINT_BUF(b1);
 		int iflink = rta_getattr_u32(tb[IFLA_LINK]);
 
-		if (iflink == 0)
+		if (iflink == 0) {
 			snprintf(buf, sizeof(buf), "%s@NONE", name);
-		else {
-			snprintf(buf, sizeof(buf),
-				 "%s@%s", name, ll_idx_n2a(iflink, b1));
+			print_null(PRINT_JSON, "link", NULL, NULL);
+		} else {
+			const char *link = ll_idx_n2a(iflink, b1);
+
+			print_string(PRINT_JSON, "link", NULL, link);
+			snprintf(buf, sizeof(buf), "%s@%s", name, link);
 			m_flag = ll_index_to_flags(iflink);
 			m_flag = !(m_flag & IFF_UP);
 		}
 	} else
 		snprintf(buf, sizeof(buf), "%s", name);
 
-	fprintf(fp, "%-16s ", buf);
+	print_string(PRINT_FP, NULL, "%-16s ", buf);
+	print_string(PRINT_JSON, "ifname", NULL, name);
 
 	if (tb[IFLA_OPERSTATE])
 		print_operstate(fp, rta_getattr_u8(tb[IFLA_OPERSTATE]));
 
 	if (pfilter->family == AF_PACKET) {
 		SPRINT_BUF(b1);
+
 		if (tb[IFLA_ADDRESS]) {
-			color_fprintf(fp, COLOR_MAC, "%s ",
-					ll_addr_n2a(RTA_DATA(tb[IFLA_ADDRESS]),
-						RTA_PAYLOAD(tb[IFLA_ADDRESS]),
-						ifi->ifi_type,
-						b1, sizeof(b1)));
+			print_color_string(PRINT_ANY, COLOR_MAC,
+					   "address", "%s ",
+					   ll_addr_n2a(
+						   RTA_DATA(tb[IFLA_ADDRESS]),
+						   RTA_PAYLOAD(tb[IFLA_ADDRESS]),
+						   ifi->ifi_type,
+						   b1, sizeof(b1)));
 		}
 	}
 
-	if (pfilter->family == AF_PACKET)
+	if (pfilter->family == AF_PACKET) {
 		print_link_flags(fp, ifi->ifi_flags, m_flag);
-
-	if (pfilter->family == AF_PACKET)
-		fprintf(fp, "\n");
+		print_string(PRINT_FP, NULL, "%s", "\n");
+	}
 	fflush(fp);
 	return 0;
 }
@@ -749,10 +1039,12 @@ static const char *link_events[] = {
 static void print_link_event(FILE *f, __u32 event)
 {
 	if (event >= ARRAY_SIZE(link_events))
-		fprintf(f, "event %d ", event);
+		print_int(PRINT_ANY, "event", "event %d ", event);
 	else {
 		if (event)
-			fprintf(f, "event %s ", link_events[event]);
+			print_string(PRINT_ANY,
+				     "event", "event %s ",
+				     link_events[event]);
 	}
 }
 
@@ -808,41 +1100,63 @@ int print_linkinfo(const struct sockaddr_nl *who,
 		return -1;
 
 	if (n->nlmsg_type == RTM_DELLINK)
-		fprintf(fp, "Deleted ");
-
-	fprintf(fp, "%d: ", ifi->ifi_index);
-	color_fprintf(fp, COLOR_IFNAME, "%s",
-		      tb[IFLA_IFNAME] ? rta_getattr_str(tb[IFLA_IFNAME]) : "<nil>");
+		print_bool(PRINT_ANY, "deleted", "Deleted ", true);
+
+	print_int(PRINT_ANY, "ifindex", "%d: ", ifi->ifi_index);
+	if (tb[IFLA_IFNAME]) {
+		print_color_string(PRINT_ANY,
+				   COLOR_IFNAME,
+				   "ifname", "%s",
+				   rta_getattr_str(tb[IFLA_IFNAME]));
+	} else {
+		print_null(PRINT_JSON, "ifname", NULL, NULL);
+		print_color_null(PRINT_FP, COLOR_IFNAME,
+				 "ifname", "%s", "<nil>");
+	}
 
 	if (tb[IFLA_LINK]) {
-		SPRINT_BUF(b1);
 		int iflink = rta_getattr_u32(tb[IFLA_LINK]);
 
 		if (iflink == 0)
-			fprintf(fp, "@NONE: ");
+			print_null(PRINT_ANY, "link", "@%s: ", "NONE");
 		else {
 			if (tb[IFLA_LINK_NETNSID])
-				fprintf(fp, "@if%d: ", iflink);
+				print_int(PRINT_ANY,
+					  "link_index", "@if%d: ", iflink);
 			else {
-				fprintf(fp, "@%s: ", ll_idx_n2a(iflink, b1));
+				SPRINT_BUF(b1);
+
+				print_string(PRINT_ANY,
+					     "link",
+					     "@%s: ",
+					     ll_idx_n2a(iflink, b1));
 				m_flag = ll_index_to_flags(iflink);
 				m_flag = !(m_flag & IFF_UP);
 			}
 		}
 	} else {
-		fprintf(fp, ": ");
+		print_string(PRINT_FP, NULL, ": ", NULL);
 	}
 	print_link_flags(fp, ifi->ifi_flags, m_flag);
 
 	if (tb[IFLA_MTU])
-		fprintf(fp, "mtu %u ", rta_getattr_u32(tb[IFLA_MTU]));
+		print_int(PRINT_ANY,
+			  "mtu", "mtu %u ",
+			  rta_getattr_u32(tb[IFLA_MTU]));
 	if (tb[IFLA_XDP])
 		xdp_dump(fp, tb[IFLA_XDP]);
 	if (tb[IFLA_QDISC])
-		fprintf(fp, "qdisc %s ", rta_getattr_str(tb[IFLA_QDISC]));
+		print_string(PRINT_ANY,
+			     "qdisc",
+			     "qdisc %s ",
+			     rta_getattr_str(tb[IFLA_QDISC]));
 	if (tb[IFLA_MASTER]) {
 		SPRINT_BUF(b1);
-		fprintf(fp, "master %s ", ll_idx_n2a(rta_getattr_u32(tb[IFLA_MASTER]), b1));
+
+		print_string(PRINT_ANY,
+			     "master",
+			     "master %s ",
+			     ll_idx_n2a(rta_getattr_u32(tb[IFLA_MASTER]), b1));
 	}
 
 	if (tb[IFLA_OPERSTATE])
@@ -855,7 +1169,10 @@ int print_linkinfo(const struct sockaddr_nl *who,
 		SPRINT_BUF(b1);
 		int group = rta_getattr_u32(tb[IFLA_GROUP]);
 
-		fprintf(fp, "group %s ", rtnl_group_n2a(group, b1, sizeof(b1)));
+		print_string(PRINT_ANY,
+			     "group",
+			     "group %s ",
+			     rtnl_group_n2a(group, b1, sizeof(b1)));
 	}
 
 	if (filter.showqueue)
@@ -866,47 +1183,68 @@ int print_linkinfo(const struct sockaddr_nl *who,
 
 	if (!filter.family || filter.family == AF_PACKET || show_details) {
 		SPRINT_BUF(b1);
-		fprintf(fp, "%s", _SL_);
-		fprintf(fp, "    link/%s ", ll_type_n2a(ifi->ifi_type, b1, sizeof(b1)));
 
+		print_string(PRINT_FP, NULL, "%s", _SL_);
+		print_string(PRINT_ANY,
+			     "link_type",
+			     "    link/%s ",
+			     ll_type_n2a(ifi->ifi_type, b1, sizeof(b1)));
 		if (tb[IFLA_ADDRESS]) {
-			color_fprintf(fp, COLOR_MAC, "%s",
-				      ll_addr_n2a(RTA_DATA(tb[IFLA_ADDRESS]),
-						  RTA_PAYLOAD(tb[IFLA_ADDRESS]),
-						  ifi->ifi_type,
-						  b1, sizeof(b1)));
+			print_color_string(PRINT_ANY,
+					   COLOR_MAC,
+					   "address",
+					   "%s",
+					   ll_addr_n2a(RTA_DATA(tb[IFLA_ADDRESS]),
+						       RTA_PAYLOAD(tb[IFLA_ADDRESS]),
+						       ifi->ifi_type,
+						       b1, sizeof(b1)));
 		}
 		if (tb[IFLA_BROADCAST]) {
-			if (ifi->ifi_flags&IFF_POINTOPOINT)
-				fprintf(fp, " peer ");
-			else
-				fprintf(fp, " brd ");
-			color_fprintf(fp, COLOR_MAC, "%s",
-				      ll_addr_n2a(RTA_DATA(tb[IFLA_BROADCAST]),
-						  RTA_PAYLOAD(tb[IFLA_BROADCAST]),
-						  ifi->ifi_type,
-						  b1, sizeof(b1)));
+			if (ifi->ifi_flags&IFF_POINTOPOINT) {
+				print_string(PRINT_FP, NULL, " peer ", NULL);
+				print_bool(PRINT_JSON,
+					   "link_pointtopoint", NULL, true);
+			} else {
+				print_string(PRINT_FP, NULL, " brd ", NULL);
+			}
+			print_color_string(PRINT_ANY,
+					   COLOR_MAC,
+					   "broadcast",
+					   "%s",
+					   ll_addr_n2a(RTA_DATA(tb[IFLA_BROADCAST]),
+						       RTA_PAYLOAD(tb[IFLA_BROADCAST]),
+						       ifi->ifi_type,
+						       b1, sizeof(b1)));
 		}
 	}
 
 	if (tb[IFLA_LINK_NETNSID]) {
 		int id = rta_getattr_u32(tb[IFLA_LINK_NETNSID]);
 
-		if (id >= 0)
-			fprintf(fp, " link-netnsid %d", id);
-		else
-			fprintf(fp, " link-netnsid unknown");
+		if (is_json_context()) {
+			print_int(PRINT_JSON, "link_netnsid", NULL, id);
+		} else {
+			if (id >= 0)
+				print_int(PRINT_FP, NULL,
+					  " link-netnsid %d", id);
+			else
+				print_string(PRINT_FP, NULL,
+					     " link-netnsid %s", "unknown");
+		}
 	}
 
 	if (tb[IFLA_PROTO_DOWN]) {
 		if (rta_getattr_u8(tb[IFLA_PROTO_DOWN]))
-			fprintf(fp, " protodown on ");
+			print_bool(PRINT_ANY,
+				   "proto_down", " protodown on ", true);
 	}
 
 	if (show_details) {
 		if (tb[IFLA_PROMISCUITY])
-			fprintf(fp, " promiscuity %u ",
-				rta_getattr_u32(tb[IFLA_PROMISCUITY]));
+			print_uint(PRINT_ANY,
+				   "promiscuity",
+				   " promiscuity %u ",
+				   rta_getattr_u32(tb[IFLA_PROMISCUITY]));
 
 		if (tb[IFLA_LINKINFO])
 			print_linktype(fp, tb[IFLA_LINKINFO]);
@@ -915,50 +1253,68 @@ int print_linkinfo(const struct sockaddr_nl *who,
 			print_af_spec(fp, tb[IFLA_AF_SPEC]);
 
 		if (tb[IFLA_NUM_TX_QUEUES])
-			fprintf(fp, "numtxqueues %u ",
-				rta_getattr_u32(tb[IFLA_NUM_TX_QUEUES]));
+			print_uint(PRINT_ANY,
+				   "num_tx_queues",
+				   "numtxqueues %u ",
+				   rta_getattr_u32(tb[IFLA_NUM_TX_QUEUES]));
 
 		if (tb[IFLA_NUM_RX_QUEUES])
-			fprintf(fp, "numrxqueues %u ",
-				rta_getattr_u32(tb[IFLA_NUM_RX_QUEUES]));
+			print_uint(PRINT_ANY,
+				   "num_rx_queues",
+				   "numrxqueues %u ",
+				   rta_getattr_u32(tb[IFLA_NUM_RX_QUEUES]));
 
 		if (tb[IFLA_GSO_MAX_SIZE])
-			fprintf(fp, "gso_max_size %u ",
-				rta_getattr_u32(tb[IFLA_GSO_MAX_SIZE]));
+			print_uint(PRINT_ANY,
+				   "gso_max_size",
+				   "gso_max_size %u ",
+				   rta_getattr_u32(tb[IFLA_GSO_MAX_SIZE]));
 
 		if (tb[IFLA_GSO_MAX_SEGS])
-			fprintf(fp, "gso_max_segs %u ",
-				rta_getattr_u32(tb[IFLA_GSO_MAX_SEGS]));
+			print_uint(PRINT_ANY,
+				   "gso_max_segs",
+				   "gso_max_segs %u ",
+				   rta_getattr_u32(tb[IFLA_GSO_MAX_SEGS]));
 
 		if (tb[IFLA_PHYS_PORT_NAME])
-			fprintf(fp, "portname %s ",
-				rta_getattr_str(tb[IFLA_PHYS_PORT_NAME]));
+			print_string(PRINT_ANY,
+				     "phys_port_name",
+				     "portname %s ",
+				     rta_getattr_str(tb[IFLA_PHYS_PORT_NAME]));
 
 		if (tb[IFLA_PHYS_PORT_ID]) {
 			SPRINT_BUF(b1);
-			fprintf(fp, "portid %s ",
-				hexstring_n2a(RTA_DATA(tb[IFLA_PHYS_PORT_ID]),
-					      RTA_PAYLOAD(tb[IFLA_PHYS_PORT_ID]),
-					      b1, sizeof(b1)));
+			print_string(PRINT_ANY,
+				     "phys_port_id",
+				     "portid %s ",
+				     hexstring_n2a(
+					     RTA_DATA(tb[IFLA_PHYS_PORT_ID]),
+					     RTA_PAYLOAD(tb[IFLA_PHYS_PORT_ID]),
+					     b1, sizeof(b1)));
 		}
 
 		if (tb[IFLA_PHYS_SWITCH_ID]) {
 			SPRINT_BUF(b1);
-			fprintf(fp, "switchid %s ",
-				hexstring_n2a(RTA_DATA(tb[IFLA_PHYS_SWITCH_ID]),
-					      RTA_PAYLOAD(tb[IFLA_PHYS_SWITCH_ID]),
-					      b1, sizeof(b1)));
+			print_string(PRINT_ANY,
+				     "phys_switch_id",
+				     "switchid %s ",
+				     hexstring_n2a(RTA_DATA(tb[IFLA_PHYS_SWITCH_ID]),
+						   RTA_PAYLOAD(tb[IFLA_PHYS_SWITCH_ID]),
+						   b1, sizeof(b1)));
 		}
 	}
 
 
 	if ((do_link || show_details) && tb[IFLA_IFALIAS]) {
-		fprintf(fp, "%s    alias %s", _SL_,
-			rta_getattr_str(tb[IFLA_IFALIAS]));
+		print_string(PRINT_FP, NULL, "%s    ", _SL_);
+		print_string(PRINT_ANY,
+			     "ifalias",
+			     "alias %s",
+			     rta_getattr_str(tb[IFLA_IFALIAS]));
 	}
 
 	if (do_link && show_stats) {
-		fprintf(fp, "%s", _SL_);
+		print_string(PRINT_FP, NULL, "%s", _SL_);
 		__print_link_stats(fp, tb);
 	}
 
@@ -966,11 +1322,16 @@ int print_linkinfo(const struct sockaddr_nl *who,
 		struct rtattr *i, *vflist = tb[IFLA_VFINFO_LIST];
 		int rem = RTA_PAYLOAD(vflist);
 
-		for (i = RTA_DATA(vflist); RTA_OK(i, rem); i = RTA_NEXT(i, rem))
+		open_json_array(PRINT_JSON, "vfinfo_list");
+		for (i = RTA_DATA(vflist); RTA_OK(i, rem); i = RTA_NEXT(i, rem)) {
+			open_json_object(NULL);
 			print_vfinfo(fp, i);
+			close_json_object();
+		}
+		close_json_array(PRINT_JSON, NULL);
 	}
 
-	fprintf(fp, "\n");
+	print_string(PRINT_FP, NULL, "\n", NULL);
 	fflush(fp);
 	return 1;
 }
@@ -1095,123 +1456,190 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 	}
 
 	if (n->nlmsg_type == RTM_DELADDR)
-		fprintf(fp, "Deleted ");
+		print_bool(PRINT_ANY, "deleted", "Deleted ", true);
 
 	if (!brief) {
-		if (filter.oneline || filter.flushb)
-			fprintf(fp, "%u: %s", ifa->ifa_index, ll_index_to_name(ifa->ifa_index));
-		if (ifa->ifa_family == AF_INET)
-			fprintf(fp, "    inet ");
-		else if (ifa->ifa_family == AF_INET6)
-			fprintf(fp, "    inet6 ");
-		else if (ifa->ifa_family == AF_DECnet)
-			fprintf(fp, "    dnet ");
-		else if (ifa->ifa_family == AF_IPX)
-			fprintf(fp, "     ipx ");
+		if (filter.oneline || filter.flushb) {
+			const char *dev = ll_index_to_name(ifa->ifa_index);
+
+			if (is_json_context()) {
+				print_int(PRINT_JSON,
+					  "index", NULL, ifa->ifa_index);
+				print_string(PRINT_JSON, "dev", NULL, dev);
+			} else {
+				fprintf(fp, "%u: %s", ifa->ifa_index, dev);
+			}
+		}
+
+		int family = ifa->ifa_family;
+
+		if (family == AF_INET)
+			print_string(PRINT_ANY, "family", "    %s ", "inet");
+		else if (family == AF_INET6)
+			print_string(PRINT_ANY, "family", "    %s ", "inet6");
+		else if (family == AF_DECnet)
+			print_string(PRINT_ANY, "family", "    %s ", "dnet");
+		else if (family == AF_IPX)
+			print_string(PRINT_ANY, "family", "     %s ", "ipx");
 		else
-			fprintf(fp, "    family %d ", ifa->ifa_family);
+			print_int(PRINT_ANY,
+				  "family_index",
+				  "    family %d ", family);
 	}
 
 	if (rta_tb[IFA_LOCAL]) {
-		color_fprintf(fp, ifa_family_color(ifa->ifa_family), "%s",
-			      format_host_rta(ifa->ifa_family,
-					      rta_tb[IFA_LOCAL]));
+		print_color_string(PRINT_ANY,
+				   ifa_family_color(ifa->ifa_family),
+				   "local",
+				   "%s",
+				   format_host_rta(ifa->ifa_family,
+						   rta_tb[IFA_LOCAL]));
 		if (rta_tb[IFA_ADDRESS] &&
 		    memcmp(RTA_DATA(rta_tb[IFA_ADDRESS]),
 			   RTA_DATA(rta_tb[IFA_LOCAL]),
 			   ifa->ifa_family == AF_INET ? 4 : 16)) {
-			fprintf(fp, " peer ");
-			color_fprintf(fp, ifa_family_color(ifa->ifa_family),
-				      "%s", format_host_rta(ifa->ifa_family,
-				      rta_tb[IFA_ADDRESS]));
+			print_string(PRINT_FP, NULL, "%s ", "peer");
+			print_color_string(PRINT_ANY,
+					   ifa_family_color(ifa->ifa_family),
+					   "address",
+					   "%s",
+					   format_host_rta(ifa->ifa_family,
+							   rta_tb[IFA_ADDRESS]));
 		}
-		fprintf(fp, "/%d ", ifa->ifa_prefixlen);
+		print_int(PRINT_ANY, "prefixlen", "/%d", ifa->ifa_prefixlen);
 	}
 
 	if (brief)
 		goto brief_exit;
 
-	if (rta_tb[IFA_BROADCAST]) {
-		fprintf(fp, "brd ");
-		color_fprintf(fp, ifa_family_color(ifa->ifa_family), "%s ",
-			      format_host_rta(ifa->ifa_family,
-					      rta_tb[IFA_BROADCAST]));
-	}
-	if (rta_tb[IFA_ANYCAST]) {
-		fprintf(fp, "any ");
-		color_fprintf(fp, ifa_family_color(ifa->ifa_family), "%s ",
-			      format_host_rta(ifa->ifa_family,
-					      rta_tb[IFA_ANYCAST]));
-	}
-	fprintf(fp, "scope %s ", rtnl_rtscope_n2a(ifa->ifa_scope, b1, sizeof(b1)));
+	if (rta_tb[IFA_BROADCAST])
+		print_color_string(PRINT_ANY,
+				   ifa_family_color(ifa->ifa_family),
+				   "broadcast",
+				   "brd %s ",
+				   format_host_rta(ifa->ifa_family,
+						   rta_tb[IFA_BROADCAST]));
+
+	if (rta_tb[IFA_ANYCAST])
+		print_color_string(PRINT_ANY,
+				   ifa_family_color(ifa->ifa_family),
+				   "anycast",
+				   "any %s ",
+				   format_host_rta(ifa->ifa_family,
+						   rta_tb[IFA_ANYCAST]));
+
+	print_string(PRINT_ANY,
+		     "scope",
+		     "scope %s ",
+		     rtnl_rtscope_n2a(ifa->ifa_scope, b1, sizeof(b1)));
+
 	if (ifa_flags & IFA_F_SECONDARY) {
 		ifa_flags &= ~IFA_F_SECONDARY;
 		if (ifa->ifa_family == AF_INET6)
-			fprintf(fp, "temporary ");
+			print_bool(PRINT_ANY, "temporary", "temporary ", true);
 		else
-			fprintf(fp, "secondary ");
+			print_bool(PRINT_ANY, "secondary", "secondary ", true);
 	}
+
 	if (ifa_flags & IFA_F_TENTATIVE) {
 		ifa_flags &= ~IFA_F_TENTATIVE;
-		fprintf(fp, "tentative ");
+		print_bool(PRINT_ANY, "tentative", "tentative ", true);
 	}
+
 	if (ifa_flags & IFA_F_DEPRECATED) {
 		ifa_flags &= ~IFA_F_DEPRECATED;
 		deprecated = 1;
-		fprintf(fp, "deprecated ");
+		print_bool(PRINT_ANY, "deprecated", "deprecated ", true);
 	}
+
 	if (ifa_flags & IFA_F_HOMEADDRESS) {
 		ifa_flags &= ~IFA_F_HOMEADDRESS;
-		fprintf(fp, "home ");
+		print_bool(PRINT_ANY, "homeaddress", "home ", true);
 	}
+
 	if (ifa_flags & IFA_F_NODAD) {
 		ifa_flags &= ~IFA_F_NODAD;
-		fprintf(fp, "nodad ");
+		print_bool(PRINT_ANY, "nodad", "nodad ", true);
 	}
+
 	if (ifa_flags & IFA_F_MANAGETEMPADDR) {
 		ifa_flags &= ~IFA_F_MANAGETEMPADDR;
-		fprintf(fp, "mngtmpaddr ");
+		print_bool(PRINT_ANY, "managetempaddr", "mngtmpaddr ", true);
 	}
+
 	if (ifa_flags & IFA_F_NOPREFIXROUTE) {
 		ifa_flags &= ~IFA_F_NOPREFIXROUTE;
-		fprintf(fp, "noprefixroute ");
+		print_bool(PRINT_ANY, "noprefixroute", "noprefixroute ", true);
 	}
+
 	if (ifa_flags & IFA_F_MCAUTOJOIN) {
 		ifa_flags &= ~IFA_F_MCAUTOJOIN;
-		fprintf(fp, "autojoin ");
+		print_bool(PRINT_ANY, "mcautojoin", "autojoin ", true);
 	}
+
 	if (!(ifa_flags & IFA_F_PERMANENT))
-		fprintf(fp, "dynamic ");
+		print_bool(PRINT_ANY, "permanent", "dynamic ", true);
 	else
 		ifa_flags &= ~IFA_F_PERMANENT;
+
 	if (ifa_flags & IFA_F_DADFAILED) {
 		ifa_flags &= ~IFA_F_DADFAILED;
-		fprintf(fp, "dadfailed ");
+		print_bool(PRINT_ANY, "dadfailed", "dadfailed ", true);
 	}
-	if (ifa_flags)
-		fprintf(fp, "flags %02x ", ifa_flags);
+
+	if (ifa_flags) {
+		if (is_json_context()) {
+			SPRINT_BUF(flags);
+
+			snprintf(flags, sizeof(flags), "%02x", ifa_flags);
+			print_string(PRINT_JSON, "flags", NULL, flags);
+		} else {
+			fprintf(fp, "flags %02x ", ifa_flags);
+		}
+	}
+
 	if (rta_tb[IFA_LABEL])
-		fprintf(fp, "%s", rta_getattr_str(rta_tb[IFA_LABEL]));
+		print_string(PRINT_ANY,
+			     "label",
+			     "%s",
+			     rta_getattr_str(rta_tb[IFA_LABEL]));
+
 	if (rta_tb[IFA_CACHEINFO]) {
 		struct ifa_cacheinfo *ci = RTA_DATA(rta_tb[IFA_CACHEINFO]);
 
-		fprintf(fp, "%s", _SL_);
-		fprintf(fp, "       valid_lft ");
-		if (ci->ifa_valid == INFINITY_LIFE_TIME)
-			fprintf(fp, "forever");
-		else
-			fprintf(fp, "%usec", ci->ifa_valid);
-		fprintf(fp, " preferred_lft ");
-		if (ci->ifa_prefered == INFINITY_LIFE_TIME)
-			fprintf(fp, "forever");
-		else {
+		print_string(PRINT_FP, NULL, "%s", _SL_);
+		print_string(PRINT_FP, NULL, "       valid_lft ", NULL);
+
+		if (ci->ifa_valid == INFINITY_LIFE_TIME) {
+			print_uint(PRINT_JSON,
+				   "valid_life_time",
+				   NULL, INFINITY_LIFE_TIME);
+			print_string(PRINT_FP, NULL, "%s", "forever");
+		} else {
+			print_uint(PRINT_ANY,
+				   "valid_life_time", "%usec", ci->ifa_valid);
+		}
+
+		print_string(PRINT_FP, NULL, " preferred_lft ", NULL);
+		if (ci->ifa_prefered == INFINITY_LIFE_TIME) {
+			print_uint(PRINT_JSON,
+				   "preferred_life_time",
+				   NULL, INFINITY_LIFE_TIME);
+			print_string(PRINT_FP, NULL, "%s", "forever");
+		} else {
 			if (deprecated)
-				fprintf(fp, "%dsec", ci->ifa_prefered);
+				print_int(PRINT_ANY,
+					  "preferred_life_time",
+					  "%dsec",
+					  ci->ifa_prefered);
 			else
-				fprintf(fp, "%usec", ci->ifa_prefered);
+				print_uint(PRINT_ANY,
+					   "preferred_life_time",
+					   "%usec",
+					   ci->ifa_prefered);
 		}
 	}
-	fprintf(fp, "\n");
+	print_string(PRINT_FP, NULL, "%s", "\n");
 brief_exit:
 	fflush(fp);
 	return 0;
@@ -1220,6 +1648,7 @@ brief_exit:
 static int print_selected_addrinfo(struct ifinfomsg *ifi,
 				   struct nlmsg_list *ainfo, FILE *fp)
 {
+	open_json_array(PRINT_JSON, "addr_info");
 	for ( ; ainfo ;  ainfo = ainfo->next) {
 		struct nlmsghdr *n = &ainfo->h;
 		struct ifaddrmsg *ifa = NLMSG_DATA(n);
@@ -1237,10 +1666,14 @@ static int print_selected_addrinfo(struct ifinfomsg *ifi,
 		if (filter.up && !(ifi->ifi_flags&IFF_UP))
 			continue;
 
+		open_json_object(NULL);
 		print_addrinfo(NULL, n, fp);
+		close_json_object();
 	}
+	close_json_array(PRINT_JSON, NULL);
+
 	if (brief) {
-		fprintf(fp, "\n");
+		print_string(PRINT_FP, NULL, "%s", "\n");
 		fflush(fp);
 	}
 	return 0;
@@ -1731,6 +2164,12 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 	}
 
 	/*
+	 * Initialize a json_writer and open an array object
+	 * if -json was specified.
+	 */
+	new_json_obj(json, stdout);
+
+	/*
 	 * If only filter_dev present and none of the other
 	 * link filters are present, use RTM_GETLINK to get
 	 * the link device
@@ -1738,8 +2177,10 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 	if (filter_dev && filter.group == -1 && do_link == 1) {
 		if (iplink_get(0, filter_dev, RTEXT_FILTER_VF) < 0) {
 			perror("Cannot send link get request");
+			delete_json_obj();
 			exit(1);
 		}
+		delete_json_obj();
 		exit(0);
 	}
 
@@ -1761,6 +2202,7 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 		int res = 0;
 		struct ifinfomsg *ifi = NLMSG_DATA(&l->h);
 
+		open_json_object(NULL);
 		if (brief) {
 			if (print_linkinfo_brief(NULL, &l->h,
 						 stdout, NULL) == 0)
@@ -1776,6 +2218,7 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 			if (res > 0 && !do_link && show_stats)
 				print_link_stats(stdout, &l->h);
 		}
+		close_json_object();
 	}
 	fflush(stdout);
 
@@ -1783,7 +2226,7 @@ out:
 	if (ainfo)
 		free_nlmsg_chain(ainfo);
 	free_nlmsg_chain(&linfo);
-
+	delete_json_obj();
 	return 0;
 }
 
-- 
2.13.3

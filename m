From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 4/14] nes: connection manager structures and defines
Date: Tue, 07 Aug 2007 21:49:25 -0400
Message-ID: <46B92125.2070400@garzik.org>
References: <200708080052.l780qUXw004708@neteffect.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, ewg@lists.openfabrics.org,
	netdev@vger.kernel.org
To: ggrundstrom@neteffect.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36741 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750854AbXHHBt2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2007 21:49:28 -0400
In-Reply-To: <200708080052.l780qUXw004708@neteffect.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ggrundstrom@neteffect.com wrote:
> +struct ietf_mpa_frame {
> +	u8 key[IETF_MPA_KEY_SIZE];
> +	u8 flags;
> +	u8 rev;
> +	u16 priv_data_len;
> +	u8 priv_data[0];

use unsigned long, not u8, for proper alignment.

plus, as noted in other emails, you should not ever be using 'u8' for 
pointers to raw data.  We use 'void *' for that in the kernel.



> +/* CM context params */
> +struct nes_cm_tcp_context {
> +	u8   client;		
> +
> +	u32  loc_seq_num;	
> +	u32  loc_ack_num;	
> +	u32  rem_ack_num;	
> +	u32  rcv_nxt;		
> +
> +	u32  loc_id;
> +	u32  rem_id;
> +
> +	u32 snd_wnd;
> +	u32 max_snd_wnd;
> +
> +	u32 rcv_wnd;
> +	u32 mss;
> +	u8  snd_wscale;
> +	u8  rcv_wscale;
> +
> +	struct nes_cm_tsa_context tsa_cntxt;	
> +	struct timeval sent_ts;		
> +};
> +
> +struct nes_cm_listener {
> +	struct list_head list;
> +	u64 session_id;	
> +	struct nes_cm_core *core_p;
> +	u8 loc_mac[ETH_ALEN];
> +	nes_addr_t loc_addr;
> +	u16 loc_port;
> +	void *cm_id;
> +	enum nes_cm_conn_type conn_type;
> +	atomic_t ref_count;
> +};
> +
> +/* per connection node and node state information */
> +struct nes_cm_node {
> +	u64 session_id;	
> +	u32 hashkey;	
> +
> +	nes_addr_t loc_addr, rem_addr;
> +	u16 loc_port, rem_port;
> +
> +	u8 loc_mac[ETH_ALEN];	
> +	u8 rem_mac[ETH_ALEN];	
> +
> +	enum nes_cm_node_state state;	
> +	struct nes_cm_tcp_context tcp_cntxt;	
> +	struct nes_cm_core *core_p;
> +	struct sk_buff_head resend_list;
> +	struct nes_cm_node *listener;
> +	atomic_t ref_count;				
> +	struct net_device *netdev_p;
> +
> +	struct nes_cm_node  *loopbackpartner ;
> +	struct list_head retrans_list;
> +	spinlock_t retrans_list_lock;
> +	struct list_head recv_list;
> +	spinlock_t recv_list_lock;
> +	
> +	int send_write0;
> +	union {
> +		struct ietf_mpa_frame mpa_frame_p;	
> +		u8 mpa_frame_b[NES_CM_DEFAULT_MTU];
> +	};
> +	u16 mpa_frame_size;
> +	void *cm_id;
> +	struct list_head list;
> +	int accelerated;
> +	struct nes_cm_listener *listen_p;
> +	enum nes_cm_conn_type conn_type;

use tabs to make your structs reviewable, like you did with the context 
params


> +/* structure for client or CM to fill when making CM api calls. */
> +/*	- only need to set relevant data, based on op. */
> +struct nes_cm_info {
> +	union {
> +		struct iw_cm_id *cm_id;
> +		struct net_device *netdev;
> +	};
> +
> +	u16 loc_port;
> +	u16 rem_port;
> +	nes_addr_t loc_addr;
> +	nes_addr_t rem_addr;
> +
> +	enum nes_cm_conn_type  conn_type;
> +};
> +
> +/* CM event codes */
> +enum  nes_cm_event_type {
> +	NES_CM_EVENT_UNKNOWN,
> +	NES_CM_EVENT_ESTABLISHED,
> +	NES_CM_EVENT_MPA_REQ,
> +	NES_CM_EVENT_MPA_CONNECT,
> +	NES_CM_EVENT_MPA_ACCEPT,
> +	NES_CM_EVENT_MPA_ESTABLISHED,
> +	NES_CM_EVENT_CONNECTED,
> +	NES_CM_EVENT_CLOSED,
> +	NES_CM_EVENT_RESET,
> +	NES_CM_EVENT_DROPPED_PKT,
> +	NES_CM_EVENT_CLOSE_IMMED,
> +	NES_CM_EVENT_CLOSE_HARD,
> +	NES_CM_EVENT_CLOSE_CLEAN,
> +	NES_CM_EVENT_ABORTED,
> +	NES_CM_EVENT_SEND_FIRST
> +};
> +
> +/* event to post to CM event handler */
> +struct nes_cm_event {
> +	enum nes_cm_event_type type;
> +
> +	struct nes_cm_info cm_info;
> +	struct work_struct event_work;
> +	struct nes_cm_node *node_p;
> +};
> +
> +struct nes_cm_core {
> + 	enum nes_cm_node_state state;	
> +	atomic_t session_id;			
> +
> +	atomic_t listen_node_cnt;			
> +	struct nes_cm_node listen_list;	
> +	spinlock_t listen_list_lock;	
> +
> +	u32 mtu;						
> +	u32 free_tx_pkt_max;
> +	u32 rx_pkt_posted;				
> +	struct sk_buff_head tx_free_list;	
> +	atomic_t ht_node_cnt;			
> +	struct list_head connected_nodes;
> +	/* struct list_head hashtable[NES_CM_HASHTABLE_SIZE]; */
> +	spinlock_t ht_lock;				
> +
> +	struct timer_list tcp_timer;	
> +
> +	struct nes_cm_ops *api;			
> +
> +	int (*post_event)(struct nes_cm_event *event_p);
> +	atomic_t events_posted;
> +	struct workqueue_struct *event_wq;
> +	struct workqueue_struct *disconn_wq;
> +
> +	atomic_t node_cnt;
> +	u64 aborted_connects;
> +	u32 options;
> +
> +	struct nes_cm_node *current_listen_node;
> +};
> +
> +
> +#define NES_CM_SET_PKT_SIZE        (1 << 1)
> +#define NES_CM_SET_FREE_PKT_Q_SIZE (1 << 2)
> +
> +/* CM ops/API for client interface */
> +struct nes_cm_ops {
> +	int (*accelerated)(struct nes_cm_core *cm_core_p,
> +			struct nes_cm_node *node_p);
> +	struct nes_cm_listener * (*listen)(struct nes_cm_core *cm_core_p,
> +			struct nes_vnic *nesvnic, struct nes_cm_info *nfo_p);
> +	int (*stop_listener)(struct nes_cm_core *core_p,
> +			struct nes_cm_listener *cm_core_p);
> +	struct nes_cm_node * (*connect)(struct nes_cm_core *cm_core_p,
> +			struct nes_vnic *nesvnic, struct ietf_mpa_frame *mpa_frame_p,
> +			struct nes_cm_info *nfo_p);
> +	int (*close)(struct nes_cm_core *cm_core_p, struct nes_cm_node *node_p);
> +	int (*accept)(struct nes_cm_core *cm_core_p, struct ietf_mpa_frame *mpa_frame_p,
> +			struct nes_cm_node *node_p);
> +	int (*reject)(struct nes_cm_core *cm_core_p, struct ietf_mpa_frame *mpa_frame_p,
> +			struct nes_cm_node *node_p);
> +	int (*recv_pkt)(struct nes_cm_core *cm_core_p, struct nes_vnic *nesvnic,
> +			struct sk_buff *skb_p);
> +	int (*destroy_cm_core)(struct nes_cm_core *core_p);
> +	int (*get)(struct nes_cm_core *cm_core_p);
> +	int (*set)(struct nes_cm_core *core_p, u32 type, u32 value);
> +};

how many users of this interface will be in the kernel, assuming your 
submission is accepted?

